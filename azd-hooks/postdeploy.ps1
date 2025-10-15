# If env:RUN_POSTDEPLOY_SCRIPT is set to false, exit the script
if ($env:RUN_POSTDEPLOY_SCRIPT -eq $False) {
    Write-Host "Skipping Post-Deployment Script"
    exit 0
}

$ErrorActionPreference = "Stop"

# ##############################################################################
# Set Azure CLI Context
# ##############################################################################
az account set --subscription "${env:AZURE_SUBSCRIPTION_ID}"


# ##############################################################################
# Install Required Azure CLI Extensions
# ##############################################################################
az config set extension.use_dynamic_install=yes_without_prompt
az extension add -y -n "rdbms-connect"

# ##############################################################################
# Get the current user's name and access token to connect to the PostgreSQL Server
# ##############################################################################
$username=(az account show -o tsv --query "user.name")
$token=(az account get-access-token --resource=https://ossrdbms-aad.database.windows.net -o tsv --query "accessToken")
Write-Host "Access Token Retrieved for $username"

# ##############################################################################
# Add local Public IP Address to PostgreSQL Firewall,
# so we can connect to the PostgreSQL Server and run scripts
# ##############################################################################
Write-Host "Adding Firewall Rule for Local Machine IP Address..."

# Use HTTPS for IP lookup
$publicIpAddress =  (Invoke-RestMethod -Uri "https://ipinfo.io/ip")
az postgres flexible-server firewall-rule create `
    --resource-group "${env:AZURE_RESOURCE_GROUP}" `
    --name "${env:POSTGRESQL_SERVER_NAME}" `
    --rule-name "AllowAZDLocalMachine" `
    --start-ip-address $publicIpAddress `
    --end-ip-address $publicIpAddress

Write-Host "Added Firewall Rule for $publicIpAddress"
Start-Sleep -Seconds 5

# ##############################################################################
# Allow-list required PostgreSQL extensions (merge with existing)
# ##############################################################################
try {
    $requiredExtensions = @('azure_ai','vector','pg_diskann','age')
    $currentExtensions = az postgres flexible-server parameter show `
        --resource-group "${env:AZURE_RESOURCE_GROUP}" `
        --server-name "${env:POSTGRESQL_SERVER_NAME}" `
        --name azure.extensions `
        --query value -o tsv

    $currentList = @()
    if ($currentExtensions) {
        $currentList = $currentExtensions -split '\s*,\s*' |
            Where-Object { $_ -and $_.Trim() -ne '' } |
            ForEach-Object { $_.Trim().ToLower() } |
            Select-Object -Unique
    }

    $merged = ($currentList + $requiredExtensions) |
        ForEach-Object { $_.ToLower() } |
        Select-Object -Unique

    $newValue = ($merged -join ',')

    $currentExtensionsValue = if ($null -ne $currentExtensions) { $currentExtensions } else { '' }
    if ($newValue -ne $currentExtensionsValue) {
        Write-Host "Updating azure.extensions to: $newValue"
        az postgres flexible-server parameter set `
            --resource-group "${env:AZURE_RESOURCE_GROUP}" `
            --server-name "${env:POSTGRESQL_SERVER_NAME}" `
            --name azure.extensions `
            --value $newValue | Out-Null
    } else {
        Write-Host "azure.extensions already includes required values: $newValue"
    }
} catch {
    Write-Warning "Failed to ensure azure.extensions allow-list: $($_.Exception.Message)"
}

# ##############################################################################
# Set shared_preload_libraries parameter in PostgreSQL (required libraries)
# ##############################################################################
az postgres flexible-server parameter set `
    --resource-group "${env:AZURE_RESOURCE_GROUP}" `
    --server-name "${env:POSTGRESQL_SERVER_NAME}" `
    --subscription "${env:AZURE_SUBSCRIPTION_ID}" `
    --name shared_preload_libraries `
    --value "age,pg_cron,pg_stat_statements" | Out-Null

# ##############################################################################
# Get workspace key 
# ##############################################################################


# Recreate escaped service endpoint/key variables (were removed earlier)
$openaiEndpointEscaped   = ($env:AZURE_OPENAI_ENDPOINT   -replace "'","''")
$openaiKeyEscaped        = ($env:AZURE_OPENAI_KEY        -replace "'","''")
$languageEndpointEscaped = ($env:LANGUAGE_SERVICE_ENDPOINT -replace "'","''")
$languageKeyEscaped      = ($env:LANGUAGE_SERVICE_KEY      -replace "'","''")

if (-not $openaiEndpointEscaped -or -not $openaiKeyEscaped) {
    Write-Host "[postdeploy] OpenAI endpoint/key missing; embedding creation may fail" -ForegroundColor Yellow
}
if (-not $languageEndpointEscaped -or -not $languageKeyEscaped) {
    Write-Host "[postdeploy] Language service endpoint/key missing; language extension settings will be blank" -ForegroundColor Yellow
}



# ##############################################################################
# Create Database Schema
# ##############################################################################
Write-Host "Configuring Database Schema..."

# Token-replace ${AML_ENDPOINT_KEY} in the schema script and execute
$dbSqlPath = "$PSScriptRoot/../scripts/sql/deploy-database-tables.sql"
$dbSql = Get-Content -Path $dbSqlPath -Raw
$dbSql = $dbSql.Replace('${OPENAI_ENDPOINT}', $openaiEndpointEscaped)
$dbSql = $dbSql.Replace('${OPENAI_KEY}', $openaiKeyEscaped)
$dbSql = $dbSql.Replace('${LANGUAGE_ENDPOINT}', $languageEndpointEscaped)
$dbSql = $dbSql.Replace('${LANGUAGE_KEY}', $languageKeyEscaped)
$dbTempPath = "$PSScriptRoot/../scripts/sql/deploy-database-tables.tmp.sql"
Set-Content -Path $dbTempPath -Value $dbSql

az postgres flexible-server execute `
          --admin-user "$username" `
          --admin-password "$token" `
          --name "${env:POSTGRESQL_SERVER_NAME}" `
          --database-name "${env:POSTGRESQL_DATABASE_NAME}" `
          --file-path $dbTempPath

Remove-Item -Path $dbTempPath -ErrorAction SilentlyContinue

#Remove-Item -Path $dbTempPath -ErrorAction SilentlyContinue

# Create triggers and semantic_reranker function.
$dbSqlPath = "$PSScriptRoot/../scripts/sql/create-functions-and-triggers.sql"
$dbSql = Get-Content -Path $dbSqlPath -Raw
$dbTempPathT = "$PSScriptRoot/../scripts/sql/create-functions-and-triggers.tmp.sql"
Set-Content -Path $dbTempPathT -Value $dbSql

az postgres flexible-server execute `
          --admin-user "$username" `
          --admin-password "$token" `
          --name "${env:POSTGRESQL_SERVER_NAME}" `
          --database-name "${env:POSTGRESQL_DATABASE_NAME}" `
          --file-path $dbTempPathT

Remove-Item -Path $dbTempPathT -ErrorAction SilentlyContinue

Write-Host "Database Schema Configured"

# Clean up temp file
#Remove-Item -Path $dbTempPath -ErrorAction SilentlyContinue

Write-Host "Load Graph Data"
# Load Graph Data from tables into Apache AGE graph
$dbSqlPath = "$PSScriptRoot/../scripts/sql/load-graph-from-tables.sql"
az postgres flexible-server execute `
          --admin-user "$username" `
          --admin-password "$token" `
          --name "${env:POSTGRESQL_SERVER_NAME}" `
          --database-name "${env:POSTGRESQL_DATABASE_NAME}" `
          --file-path $dbSqlPath

Write-Host "Graph Data Loaded"

# ##############################################################################
# Grant Database Permissions to API Identity
# ##############################################################################
Write-Host "Granting Database Permissions to API App Managed Identity..."

Write-Host "Writing grant-permissions.tmp.sql script with API App managed identity name..."

# Read sql script with environment variable placeholders
$sqlScript = Get-Content -Path "$PSScriptRoot/../scripts/sql/grant-permissions.sql" -Raw

# Replace environment variable placeholders
$sqlScript = $sqlScript.Replace('${env:POSTGRESQL_DATABASE_NAME}', $env:POSTGRESQL_DATABASE_NAME)
$sqlScript = $sqlScript.Replace('${env:SERVICE_API_IDENTITY_PRINCIPAL_NAME}', $env:SERVICE_API_IDENTITY_PRINCIPAL_NAME)

# Write sql file using a variable for consistency
$grantTempPath = "$PSScriptRoot/../scripts/sql/grant-permissions.tmp.sql"
Set-Content -Path $grantTempPath -Value $sqlScript

# Run script
az postgres flexible-server execute `
          --admin-user "$username" `
          --admin-password "$token" `
          --name "${env:POSTGRESQL_SERVER_NAME}" `
          --database-name "${env:POSTGRESQL_DATABASE_NAME}" `
          --file-path $grantTempPath

Remove-Item -Path $grantTempPath -ErrorAction SilentlyContinue

Write-Host "Database Permissions Granted to API App Managed Identity"



# ##############################################################################
# Upload Seed Files to Blob Storage
# ##############################################################################

Write-Host "Uploading Seed Data Files to Blob Storage..."

az storage blob upload `
    --auth-mode login `
    --overwrite true `
    --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
    --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
    --name "1/sow/Statement_of_Work_Adatum_Corporation_Woodgrove_Bank_20241101.pdf" `
    --file "./data/sample_docs/Seeded_Data/Statement_of_Work_Adatum_Corporation_Woodgrove_Bank_20241101.pdf"

az storage blob upload `
    --auth-mode login `
    --overwrite true `
    --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
    --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
    --name "2/sow/Statement_of_Work_Contoso_Ltd_Woodgrove_Bank_20240601.pdf" `
    --file "./data/sample_docs/Seeded_Data/Statement_of_Work_Contoso_Ltd_Woodgrove_Bank_20240601.pdf"

az storage blob upload `
    --auth-mode login `
    --overwrite true `
    --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
    --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
    --name "3/sow/Statement_of_Work_Lucerne_Publishing_Woodgrove_Bank_20241201.pdf" `
    --file "./data/sample_docs/Exercise_2_Load_SOW_Invoices/Statement_of_Work_Lucerne_Publishing_Woodgrove_Bank_20241201.pdf"

az storage blob upload `
    --auth-mode login `
    --overwrite true `
    --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
    --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
    --name "4/sow/Statement_of_Work_Trey_Research_Woodgrove_Bank_20241111.pdf" `
    --file "./data/sample_docs/Seeded_Data/Statement_of_Work_Trey_Research_Woodgrove_Bank_20241111.pdf"

az storage blob upload `
    --auth-mode login `
    --overwrite true `
    --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
    --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
    --name "5/sow/Statement_of_Work_VanArsdel_Ltd_Woodgrove_Bank_20241001.pdf" `
    --file "./data/sample_docs/Seeded_Data/Statement_of_Work_VanArsdel_Ltd_Woodgrove_Bank_20241001.pdf"

az storage blob upload `
    --auth-mode login `
    --overwrite true `
    --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
    --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
    --name "1/invoice/INV-AC2024-001.pdf" `
    --file "./data/sample_docs/Seeded_Data/INV-AC2024-001.pdf"

az storage blob upload `
    --auth-mode login `
    --overwrite true `
    --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
    --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
    --name "2/invoice/INV-AC2024-002.pdf" `
    --file "./data/sample_docs/Seeded_Data/INV-AC2024-002.pdf"

az storage blob upload `
    --auth-mode login `
    --overwrite true `
    --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
    --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
    --name "3/invoice/INV-AC2024-003.pdf" `
    --file "./data/sample_docs/Seeded_Data/INV-AC2024-003.pdf"

az storage blob upload `
    --auth-mode login `
    --overwrite true `
    --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
    --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
    --name "4/invoice/INV-TR2024-001.pdf" `
    --file "./data/sample_docs/Seeded_Data/INV-TR2024-001.pdf"

Write-Host "Sample Files Uploaded to Blob Storage"

# # ##############################################################################
# # Create Event Grid Subscription with BlobCreated & BlobUpdated Webhook
# # - this must be created after the app is deployed, otherwise the webhook validation will fail
# # ##############################################################################
# Write-Host "Creating Event Grid 'StorageBlob' Subscription with BlobCreated & BlobUpdated Webhook..."

# $eventGridStorageBlobSubscriptionExists = az eventgrid system-topic event-subscription list `
#     --resource-group "${env:AZURE_RESOURCE_GROUP}" `
#     --system-topic-name "${env:STORAGE_EVENTGRID_SYSTEM_TOPIC_NAME}" `
#     --query "[?name=='StorageBlob']" `
#     --output tsv

# if (-not $eventGridStorageBlobSubscriptionExists) {
#     az eventgrid system-topic event-subscription create `
#         --name "StorageBlob" `
#         --system-topic-name "${env:STORAGE_EVENTGRID_SYSTEM_TOPIC_NAME}" `
#         --endpoint "${env:SERVICE_API_ENDPOINT_URL}/webhooks/storage-blob" `
#         --included-event-types "Microsoft.Storage.BlobCreated" "Microsoft.Storage.BlobUpdated" `
#         --subject-begins-with "/blobServices/default/containers/${env:AZURE_STORAGE_CONTAINER_NAME}/blobs/" `
#         --resource-group "${env:AZURE_RESOURCE_GROUP}"
# }

# Write-Host "Event Grid Subscription 'StorageBlob' Created"


# ##############################################################################
# Update .env file to prevent postdeploy script from running again (this ensures that the script runs only once)
# ##############################################################################

azd env set "RUN_POSTDEPLOY_SCRIPT" "false"

# ##############################################################################
# Remove transient build-time env file from UserPortal (cleanup)
# ##############################################################################
try {
    $envLocalPath = Join-Path $PSScriptRoot "..\src\userportal\.env.local"
    if (Test-Path $envLocalPath) {
        Remove-Item $envLocalPath -Force
        Write-Host "Removed local build env file: $envLocalPath" -ForegroundColor DarkGray
    } else {
        Write-Host ".env.local not present (nothing to clean)" -ForegroundColor DarkGray
    }
} catch {
    Write-Warning "Failed to remove .env.local: $($_.Exception.Message)"
}

# ##############################################################################
# Write completion message
# ##############################################################################

Write-Host "***"
Write-Host "Deployment Completed! Please read the docs at https://aka.ms/pg-byoac-docs for next steps."
Write-Host "***"
