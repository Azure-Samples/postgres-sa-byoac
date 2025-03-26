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

$publicIpAddress =  (Invoke-RestMethod -Uri "http://ipinfo.io/ip")
az postgres flexible-server firewall-rule create `
    --resource-group "${env:AZURE_RESOURCE_GROUP}" `
    --name "${env:POSTGRESQL_SERVER_NAME}" `
    --rule-name "AllowAZDLocalMachine" `
    --start-ip-address $publicIpAddress `
    --end-ip-address $publicIpAddress

Write-Host "Added Firewall Rule for $publicIpAddress"
Start-Sleep -Seconds 5

# ##############################################################################
# Create Database Schema
# ##############################################################################
Write-Host "Configuring Database Schema..."

az postgres flexible-server execute `
          --admin-user "$username" `
          --admin-password "$token" `
          --name "${env:POSTGRESQL_SERVER_NAME}" `
          --database-name "${env:POSTGRESQL_DATABASE_NAME}" `
          --file-path "$PSScriptRoot/../scripts/sql/deploy-database-tables.sql"

Write-Host "Database Schema Configured"

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

# Write sql file 
Set-Content -Path "$PSScriptRoot/../scripts/sql/grant-permissions.tmp.sql" -Value $sqlScript

# Run script
az postgres flexible-server execute `
          --admin-user "$username" `
          --admin-password "$token" `
          --name "${env:POSTGRESQL_SERVER_NAME}" `
          --database-name "${env:POSTGRESQL_DATABASE_NAME}" `
          --file-path "$PSScriptRoot/../scripts/sql/grant-permissions.tmp.sql"

Write-Host "Database Permissions Granted to API App Managed Identity"

# ##############################################################################
# Upload Sample Files to Blob Storage
# ##############################################################################

Write-Host "Uploading Sample Files to Blob Storage..."

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "1/sow/Statement_of_Work_TailWind_Cloud_Solutions_Woodgrove_Bank_20241101.pdf" `
#     --file "./data/sample_docs/model_training/Statement_of_Work_TailWind_Cloud_Solutions_Woodgrove_Bank_20241101.pdf"

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "2/sow/Statement_of_Work_Contoso_DevOps_Services_Woodgrove_Bank_20240601.pdf" `
#     --file "./data/sample_docs/model_training/Statement_of_Work_Contoso_DevOps_Services_Woodgrove_Bank_20240601.pdf"

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "3/sow/Statement_of_Work_Lucerne_Publishing_Woodgrove_Bank_20241201.pdf" `
#     --file "./data/sample_docs/model_training/Statement_of_Work_Lucerne_Publishing_Woodgrove_Bank_20241201.pdf"

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "4/sow/Statement_of_Work_Wide_World_Engineering_Woodgrove_Bank_20241001.pdf" `
#     --file "./data/sample_docs/model_training/Statement_of_Work_Wide_World_Engineering_Woodgrove_Bank_20241001.pdf"

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "5/sow/Statement_of_Work_Trey_Research_Inc_Woodgrove_Bank_20240501.pdf" `
#     --file "./data/sample_docs/model_training/Statement_of_Work_Trey_Research_Inc_Woodgrove_Bank_20240501.pdf"

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "1/invoice/INV-TWC2024-001.pdf" `
#     --file "./data/sample_docs/model_training/INV-TWC2024-001.pdf"

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "2/invoice/INV-TWC2024-002.pdf" `
#     --file "./data/sample_docs/model_training/INV-TWC2024-002.pdf"

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "3/invoice/INV-TWC2024-003.pdf" `
#     --file "./data/sample_docs/model_training/INV-TWC2024-003.pdf"

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "4/invoice/INV-TWC2024-004.pdf" `
#     --file "./data/sample_docs/model_training/INV-TWC2024-004.pdf"

# az storage blob upload `
#     --auth-mode login `
#     --overwrite true `
#     --account-name "${env:AZURE_STORAGE_ACCOUNT_NAME}" `
#     --container-name "${env:AZURE_STORAGE_CONTAINER_NAME}" `
#     --name "5/invoice/INV-WWE2024-001.pdf" `
#     --file "./data/sample_docs/model_training/INV-WWE2024-001.pdf"

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
# Deploy Chosen Cross Encoder Model to the Azure ML Workspace
# ##############################################################################

# Capture start time of model deploy
$startTime = [datetime]::Now
Write-Host "Model Deploy Start Time: $startTime"

Write-Host "If a model was chosen, now deploying Cross Encoder Model to the Azure ML Workspace..."
Write-Host "Chosen model is: $env:DEPLOY_AML_MODEL"

switch ($env:DEPLOY_AML_MODEL) {
    "mini"  { & (Resolve-Path "$PSScriptRoot\..\scripts\aml\deploy_model_mini.ps1") -ErrorAction Stop }
    "bge"   { & (Resolve-Path "$PSScriptRoot\..\scripts\aml\deploy_model_bge.ps1") -ErrorAction Stop }
    "none"  { Write-Host "Skipping Semantic Re-ranker post-deployment script." }
    default { Write-Error "Unknown DEPLOY_AML_MODEL value: $env:DEPLOY_AML_MODEL" }
}

# Capture end time of model deploy and calculate duration
$endTime = [datetime]::Now
$duration = $endTime - $startTime

# Write out the duration of the model deploy
Write-Host "Model Deploy End Time: $endTime"
Write-Host ("Model Deploy Total Duration: {0} hours {1} minutes {2} seconds" -f $duration.Hours, $duration.Minutes, $duration.Seconds)

# ##############################################################################
# Update .env file to prevent postdeploy script from running again (this ensures that the script runs only once)
# ##############################################################################

azd env set "RUN_POSTDEPLOY_SCRIPT" "false"

# ##############################################################################
# Write completion message
# ##############################################################################

Write-Host "***"
Write-Host "Deployment Completed! Please read the docs at https://aka.ms/pg-byoac-docs for next steps."
Write-Host "***"
