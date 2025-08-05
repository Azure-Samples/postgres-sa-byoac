@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for resources')
param location string

@minLength(1)
@maxLength(90)
@description('Name of the resource group')
param resourceGroupName string

@description('Location for the Azure AI Foundry account. This does not need to be the same as the primary location for resources.')
@allowed([ // Limit to regions where both Cohere-rerank-v3.5 and Abstractive summarization are available.
  'eastus'
  'eastus2'
  'northcentralus'
  'southcentralus'
  //'swedencentral'
  'westus'
  //'westus3'
])
param aiFoundryLocation string

@description('Name of the PostgreSQL database')
param postgresqlDatabaseName string = 'contracts'

@description('Version of the OpenAI model to deploy')
@allowed([
  '2024-05-13'
  '2024-08-06'
  '2024-11-20'
])
param openAiModelVersion string

@description('Defines the model deployments for Azure OpenAI in Azure AI Foundry')
param openAiModelDeployments array = [
      {
        name: 'completions'
        sku: {
          name: 'Standard'
          capacity: 10
        }
        model: {
          name: 'gpt-4o'
          version: openAiModelVersion
          format: 'OpenAI'
        }
      }
      {
        name: 'embeddings'
        sku: {
          name: 'Standard'
          capacity: 10
        }
        model: {
          name: 'text-embedding-ada-002'
          version: '2'
          format: 'OpenAI'
        }
      }
    ]

@description('Determines whether to run the post-deployment script')
param runPostDeployScript bool

@description('Determines whether the user portal app already exists')
param userPortalExists bool
@secure()
param portalDefinition object

/*
@description('The model ID for the rerank model.')
param rerankModelId string = 'azureml://registries/azureml-cohere/models/Cohere-rerank-v3.5'
*/

// Variables
var abbrs = loadJsonContent('./abbreviations.json')
var blobStorageContainerName = 'documents'
var graphContainerName = 'graph'
var principalId = deployer().objectId // Set to object id of the user deploying the template
var principalName string = deployer().userPrincipalName // Set to user principal name of the user deploying the template
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location, resourceGroupName))
// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

targetScope = 'subscription'

@description('Creates a resource group for the deployment.')
resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

@description('Creates a shared key vault for the deployment.')
module keyVault './shared/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    tags: tags
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    principalId: principalId
  }
  scope: rg
}

@description('Creates an Azure App Configuration for the deployment.')
module appConfig './shared/app-configuration.bicep' = {
  name: 'appConfig'
  params: {
    location: location
    tags: tags
    name: '${abbrs.appConfigurationConfigurationStores}${resourceToken}'
    principalId: principalId
    keyVaultName: keyVault.outputs.name
  }
  scope: rg
}

@description('Creates a container registry for the deployment.')
module registry './shared/registry.bicep' = {
  name: 'registry'
  params: {
    location: location
    tags: tags
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
  }
  scope: rg
}

@description('Creates a monitoring solution for the deployment.')
module monitoring './shared/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    tags: tags
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
  }
  scope: rg
}

@description('Creates a managed app environment for the deployment.')
module appsEnv './shared/apps-env.bicep' = {
  name: 'appsEnv'
  params: {
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    tags: tags //union(tags, { 'azd-service-name': 'web' })
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
  }
  scope: rg
}

@description('Creates a shared Azure Storage account.')
module storage './shared/storage.bicep' = {
  name: 'storage'
  params: {
    appConfigName: appConfig.outputs.name
    containers: [
      {
        name: blobStorageContainerName
        publicAccess: 'None'
      }
      {
        name: graphContainerName
        publicAccess: 'None'
      }
    ]
    files: []
    location: location
    name: '${abbrs.storageStorageAccounts}${resourceToken}'
    principalId: principalId
    tags: tags
  }
  scope: rg
}

module eventGridSystemTopicStorage './shared/eventgrid-system-topic.bicep' = {
  name: 'eventGridSystemTopicStorage'
  params: {
    topicType: 'Microsoft.Storage.StorageAccounts'
    systemTopicName: '${abbrs.eventGridDomainsTopics}${storage.outputs.name}'
    sourceResourceId: storage.outputs.id
    location: location
  }
  scope: rg
}

module documentIntelligence './shared/document-intelligence.bicep' = {
  name: 'documentIntelligence'
  params: {
    location: location
    name: '${abbrs.documentIntelligence}${resourceToken}'
    skuName: 'S0'
    tags: tags
    keyVaultName: keyVault.outputs.name
  }
  scope: rg
}

// Create an Azure AI Foundry account.
@description('Creates the Azure AI Foundry account with a hub, project, and model deployments.')
module aiFoundry './shared/ai-foundry-account.bicep' = {
  name: 'aiFoundry'
  params: {
    // Foundry parameters
    location: aiFoundryLocation
    accountName: '${abbrs.azureAiFoundryAccount}${resourceToken}'
    // Security role parameters
    princialId: principalId
    postgreSqlServerPrincipalId: postgreSqlServer.outputs.principalId
    tags: tags
  }
  scope: rg
}

module hub './shared/ai-foundry-hub.bicep' = {
  name: 'hub'
  params: {
    hubName: '${abbrs.azureAiFoundryHub}${resourceToken}'
    hubFriendlyName: 'AI Foundry Hub'
    hubDescription: 'AI Foundry Hub for shared AI resources'
    location: aiFoundryLocation
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    keyVaultName: keyVault.outputs.name
    containerRegistryName: registry.outputs.name
    storageAccountName: storage.outputs.name
  }
  scope: rg
  dependsOn: [ aiFoundry ]
}

module project './shared/ai-foundry-project.bicep' = {
  name: 'project'
  params: {
    projectName: '${abbrs.azureAiFoundryProject}${resourceToken}'
    projectFriendlyName: 'AI Foundry Project'
    location: aiFoundryLocation
    hubName: hub.outputs.name
    aiFoundryAccountName: aiFoundry.outputs.name
    tags: tags
    openAIModelDeployments: openAiModelDeployments
    appConfigName: appConfig.outputs.name
    keyVaultName: keyVault.outputs.name
    princialId: principalId
    postgreSqlServerPrincipalId: postgreSqlServer.outputs.principalId
  }
  scope: rg
}

/*
@description('Create a marketplace subscription for the rerank model within the AI Foundry project.')
module rerankModelSubscription './shared/rerank-model-subscription.bicep' = {
  name: 'rerankModelSubscription'
  params: {
    modelId: rerankModelId
    workspaceName: project.outputs.name
  }
  scope: rg
}

@description('Create a serverless endpoint for the rerank model within the AI Foundry project.')
module rerankModelEndpoint './shared/rerank-model-endpoint.bicep' = {
  name: 'rerankModelEndpoint'
  params: {
    workspaceName: project.outputs.name
    location: aiFoundryLocation
    modelId: rerankModelId
    tags: tags
  }
  dependsOn: [
    project
    rerankModelSubscription
  ]
  scope: rg
}
*/

@description('Creates a user portal app for the deployment.')
module userPortalApp './app/UserPortal.bicep' = {
  name: 'UserPortal'
  params: {
    name: '${abbrs.appContainerApps}portal-${resourceToken}'
    location: location
    tags: tags
    keyvaultName: keyVault.outputs.name
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}portal-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: userPortalExists
    appDefinition: portalDefinition
    envSettings: [
      {
        name: 'SERVICE_API_ENDPOINT_URL'
        value: apiApp.outputs.uri
      }
      {
        name: 'ApplicationInsights__ConnectionString'
        value: monitoring.outputs.appInsightsConnectionString
      }
    ]
    secretSettings: []
  }
  scope: rg
}

@description('Creates an API app for the deployment.')
module apiApp './app/API.bicep' = {
  name: 'API'
  params: {
    name: '${abbrs.appContainerApps}api-${resourceToken}'
    location: location
    tags: tags
    appConfigName: appConfig.outputs.name
    keyVaultName: keyVault.outputs.name
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}api-${resourceToken}'
    storageAccountName: storage.outputs.name
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    documentIntelligenceName: documentIntelligence.outputs.name
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: userPortalExists
    appDefinition: portalDefinition
    aiFoundryAccountName: aiFoundry.outputs.name
    aiFoundryProjectName: project.outputs.name
    envSettings: [
      {
        name: 'ApplicationInsights__ConnectionString'
        value: monitoring.outputs.appInsightsConnectionString
      }
    ]
    secretSettings: []
  }
  scope: rg
}

@description('Creates a PostgreSQL server for the deployment.')
module postgreSqlServer './shared/postgresql-server.bicep' = {
  name: 'postgreSqlServer'
  params: {
    location: location
    serverName: '${abbrs.dBforPostgreSQLServers}${resourceToken}'
    skuName: 'Standard_B2ms'
    skuTier: 'Burstable'
    highAvailabilityMode: 'Disabled'
    storageAccountName: storage.outputs.name
    tags: tags
    appConfigName: appConfig.outputs.name
  }
  scope: rg
}

@description('Creates an admin account for the PostgreSQL server for the user running the deployment.')
module postgreSqlAdmin './shared/postgresql-administrator.bicep' = {
  name: 'serverAdmin'
  params: {
    postgreSqlServerName: postgreSqlServer.outputs.name
    principalId: principalId
    principalName: principalName
    principalType: 'User'
    principalTenantId: deployer().tenantId
  }
  scope: rg
  dependsOn: [ apiApp ]
}

@description('Creates an admin account for the API App on the PostgreSQL server.')
module apiAppPostgreSqlAdmin './shared/postgresql-administrator.bicep' = {
  name: 'apiAppPostgresqlAdmin'
  params: {
    postgreSqlServerName: postgreSqlServer.outputs.name
    principalId: apiApp.outputs.identityPrincipalId
    principalName: apiApp.outputs.identityPrincipalName
  }
  scope: rg
}

@description('Creates a new database on the PostgreSQL server.')
module postgreSqlDatabase './shared/postgresql-database.bicep' = {
  name: 'postgresqlDatabase'
  params: {
    serverName: postgreSqlServer.outputs.name
    databaseName: postgresqlDatabaseName
    appConfigName: appConfig.outputs.name
  }
  dependsOn: [apiAppPostgreSqlAdmin, postgreSqlAdmin] // Be sure to set dependsOn to ensure modules that create server admins are completed before provisioning database (resolves a potential permissions issue)
  scope: rg
}

output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = registry.outputs.loginServer
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_APP_CONFIG_ENDPOINT string = appConfig.outputs.endpoint

output AZURE_STORAGE_ACCOUNT_NAME string = storage.outputs.name
output AZURE_STORAGE_CONTAINER_NAME string = blobStorageContainerName

output STORAGE_EVENTGRID_SYSTEM_TOPIC_NAME string = eventGridSystemTopicStorage.outputs.name

output POSTGRESQL_SERVER_NAME string = postgreSqlServer.outputs.name
output POSTGRESQL_DATABASE_NAME string = postgresqlDatabaseName

output SERVICE_API_IDENTITY_PRINCIPAL_NAME string = apiApp.outputs.identityPrincipalName

output SERVICE_USERPORTAL_ENDPOINT_URL string = userPortalApp.outputs.uri
output SERVICE_API_ENDPOINT_URL string = apiApp.outputs.uri

//output RERANK_INFERENCE_ENDPOINT string = rerankModelEndpoint.outputs.inferenceEndpoint

output RUN_POSTDEPLOY_SCRIPT bool = runPostDeployScript
