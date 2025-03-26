@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Name of the resource group')
param resourceGroupName string

@description('User Principal Name of the user deploying the template')
param principalName string // this is passed in, since the Bicep 'deployer()' function doesn't make this value available

@description('Principal Type of the user deploying the template')
param principalType string = 'User'

@description('Name of the PostgreSQL database')
param postgresqlDatabaseName string = 'contracts'

@description('Determines what model to deploy to the Azure Machine Learning workspace used for Semantic Re-ranking')
@allowed([
  'mini'
  'bge'
  'none'
])
param deployAMLModel string

@description('Determines whether to deploy the OpenAI models')
param deployOpenAIModels bool = true // default to true

param runPostDeployScript bool

param userPortalExists bool
@secure()
param portalDefinition object

param existingOpenAiInstance object = {
  name: ''
  subscriptionId: ''
  resourceGroup: ''
}

var principalId = deployer().objectId // Set to object id of the user deploying the template

var blobStorageContainerName = 'documents'
var graphContainerName = 'graph'

var deployOpenAi = empty(existingOpenAiInstance.name)
// var azureOpenAiEndpoint = deployOpenAi ? openAi.outputs.endpoint : customerOpenAi.properties.endpoint
// var azureOpenAi = deployOpenAi ? openAiInstance : existingOpenAiInstance
// var openAiInstance = {
//   name: openAi.outputs.name
//   resourceGroup: rg.name
//   subscriptionId: subscription().subscriptionId
// }

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location, resourceGroupName))

targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

resource customerOpenAiResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing =
  if (!deployOpenAi) {
    scope: subscription(existingOpenAiInstance.subscriptionId)
    name: existingOpenAiInstance.resourceGroup
  }

// resource customerOpenAi 'Microsoft.CognitiveServices/accounts@2023-05-01' existing =
//   if (!deployOpenAi) {
//     name: existingOpenAiInstance.name
//     scope: customerOpenAiResourceGroup
//   }

module keyVault './shared/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    tags: tags
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    principalId: principalId
  }
  scope: rg
}

module appConfig './shared/appconfiguration.bicep' = {
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

resource appInsights 'Microsoft.Insights/components@2022-05-01' existing = {
  name: monitoring.outputs.applicationInsightsName
  scope: rg
}

module registry './shared/registry.bicep' = {
  name: 'registry'
  params: {
    location: location
    tags: tags
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
  }
  scope: rg
}

module appsEnv './shared/apps-env.bicep' = {
  name: 'apps-env'
  params: {
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    tags: tags //union(tags, { 'azd-service-name': 'web' })
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
  }
  scope: rg
}

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
    openAIServiceName: openAi.outputs.name
    envSettings: [
      {
        name: 'ApplicationInsights__ConnectionString'
        value: monitoring.outputs.appInsightsConnectionString
      }
    ]
    secretSettings: []
  }
  scope: rg
  dependsOn: [ postgresql ]
}

module apiAppPostgresqlAdmin './shared/postgresql_administrator.bicep' = {
  name: 'apiAppPostgresqlAdmin'
  params: {
    postgresqlServerName: postgresql.outputs.serverName
    principalId: apiApp.outputs.identityPrincipalId
    principalName: apiApp.outputs.identityPrincipalName
  }
  scope: rg
}

module postgresql './shared/postgresql.bicep' = {
  name: 'postgresql'
  params: {
    location: location
    serverName: '${abbrs.dBforPostgreSQLServers}data${resourceToken}'
    skuName: 'Standard_B2ms'
    skuTier: 'Burstable'
    highAvailabilityMode: 'Disabled'
    tags: tags
    appConfigName: appConfig.outputs.name
  }
  scope: rg
}

module postgresqlAdmin './shared/postgresql_administrator.bicep' = {
  name: 'serverAdmin'
  params: {
    postgresqlServerName: postgresql.outputs.serverName
    principalId: principalId
    principalName: principalName
    principalType: principalType
    principalTenantId: deployer().tenantId
  }
  scope: rg
  dependsOn: [ apiApp ]
}

module postgresqlDatabase './shared/postgresql_database.bicep' = {
  name: 'postgresqlDatabase'
  params: {
    serverName: postgresql.outputs.serverName
    databaseName: postgresqlDatabaseName
    appConfigName: appConfig.outputs.name
  }
  dependsOn: [apiAppPostgresqlAdmin, postgresqlAdmin] // Be sure to set dependsOn to ensure modules that create server admins are completed before provisioning database (resolves a potential permissions issue)
  scope: rg
}

module openAi './shared/openai.bicep' = if (deployOpenAi) {
  name: 'openai'
  params: {
    deployments: deployOpenAIModels ? [
      {
        name: 'completions'
        sku: {
          name: 'Standard'
          capacity: 10
        }
        model: {
          name: 'gpt-4o'
          version: '2024-11-20'
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
        }
      }
    ] : []
    keyvaultName: keyVault.outputs.name
    appConfigName: appConfig.outputs.name
    principalId: principalId
    location: location
    name: '${abbrs.openAiAccounts}${resourceToken}'
    sku: 'S0'
    tags: tags
  }
  scope: rg
  dependsOn: [
    postgresql // delay until after postgresql, to prevent permissions issues with appConfig still pending
  ]
}

module storage './shared/storage.bicep' = {
  name: 'storage'
  params: {
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
    appConfigName: appConfig.outputs.name
    location: location
    name: '${abbrs.storageStorageAccounts}${resourceToken}'
    principalId: principalId
    postgresqlServerName: postgresql.outputs.serverName
    tags: tags
  }
  scope: rg
}

module eventGridSystemTopicStorage './shared/eventgrid-system-topic.bicep' = {
  name: 'eventGridSystemTopic-Storage'
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
  }
  scope: rg
}
module languageService './shared/language-service.bicep' = {
  name: 'languageService'
  params: {
    location: location
    name: '${abbrs.languageService}${resourceToken}'
    restore: false
  }
  scope: rg
}

module amlWorkspace './shared/aml-workspace.bicep' = if (deployAMLModel != 'none') {
  name: 'amlWorkspace'
  params: {
    location: location
    workspaceName: '${abbrs.machineLearningServicesWorkspaces}${resourceToken}'
    endpointName: '${abbrs.machineLearningServicesOnlineEndpoints}${resourceToken}'
    keyVaultName: keyVault.outputs.name
    appInsightsName: monitoring.outputs.applicationInsightsName
    storageAccountName: storage.outputs.name
    containerRegistryName: registry.outputs.name
    principalId: principalId
  }
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

output POSTGRESQL_SERVER_NAME string = postgresql.outputs.serverName
output POSTGRESQL_DATABASE_NAME string = postgresqlDatabaseName

output AZURE_OPENAI_ENDPOINT string = openAi.outputs.endpoint
output AZURE_OPENAI_KEY string = openAi.outputs.key

output DEPLOY_AML_MODEL string = deployAMLModel
output AZURE_AML_WORKSPACE_NAME string = (deployAMLModel != 'none') ? amlWorkspace.outputs.AML_WORKSPACE_NAME : ''
output AZURE_AML_ENDPOINT_NAME string = (deployAMLModel != 'none') ? amlWorkspace.outputs.AML_ENDPOINT_NAME : ''

output SERVICE_API_IDENTITY_PRINCIPAL_NAME string = apiApp.outputs.identityPrincipalName

output SERVICE_USERPORTAL_ENDPOINT_URL string = userPortalApp.outputs.uri
output SERVICE_API_ENDPOINT_URL string = apiApp.outputs.uri

output RUN_POSTDEPLOY_SCRIPT bool = runPostDeployScript
