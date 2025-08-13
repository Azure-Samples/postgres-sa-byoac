// *****************************************************************************
// Bicep module to create a project in a Hub within Azure AI Foundry.
// *****************************************************************************
@description('Location for the Azure AI Foundry Hub.')
@allowed([ // Limit to regions where both Cohere-rerank-v3.5 and Abstractive summarization are available.
  'eastus'
  'eastus2'
  'northcentralus'
  'southcentralus'
  //'swedencentral'
  'westus'
  //'westus3'
])
param location string

param projectName string = 'proj-${uniqueString(resourceGroup().id)}'
param projectFriendlyName string = 'AI Foundry Project'

param openAIModelDeployments array = []

@description('Tags to apply to the Azure AI Foundry resources.')
param tags object = {}

@description('The principal Id of the user running the deployment.')
param princialId string = deployer().objectId

@description('The principal Id of the PostgreSQL server to assign security roles.')
param postgreSqlServerPrincipalId string = ''

// Dependency parameters
param appConfigName string = ''
@description('The name of the AI Foundry account associated with the project.')
param aiFoundryAccountName string
@description('The name of the AI Foundry Hub where the project will be created.')
param hubName string
@description('The name of the Key Vault to store secrets.')
param keyVaultName string = ''

@description('Get a reference to the AI Foundry account.')
resource aiFoundryAccount 'Microsoft.CognitiveServices/accounts@2025-06-01' existing = {
  name: aiFoundryAccountName
}

@description('Get a reference to the App Configuration store.')
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2024-05-01' existing = if (!empty(appConfigName)) {
  name: appConfigName
}

@description('Get a reference to the AI Foundry Hub.')
resource hub 'Microsoft.MachineLearningServices/workspaces@2025-07-01-preview' existing = {
  name: hubName
}

@description('Get a reference to the Key Vault.')
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = if (!empty(keyVaultName)) {
  name: keyVaultName
}

@description('Create an project in the hub.')
resource project 'Microsoft.MachineLearningServices/workspaces@2025-07-01-preview' = {
  name: projectName
  location: location
  tags: tags
  kind: 'Project'
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: projectFriendlyName
    hbiWorkspace: false
    v1LegacyMode: false
    publicNetworkAccess: 'Enabled'
    hubResourceId: hub.id
    systemDatastoresAuthMode: 'Identity'
    enableDataIsolation: true
  }

  resource aiServicesConnection 'connections@2024-04-01-preview' = {
    name: '${project.name}-connection'
    properties: {
      category: 'AIServices'
      target: aiFoundryAccount.properties.endpoint
      authType: 'ApiKey'
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiFoundryAccount.id
      }
      credentials: {
        key: aiFoundryAccount.listKeys().key1
      }
    }
  }
}

@batchSize(1)
@description('Create the Azure OpenAI in AI Foundry model deployments.')
resource models 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = [
  for deployment in openAIModelDeployments: {
    name: deployment.name
    parent: aiFoundryAccount
    sku: {
      name: deployment.sku.name
      capacity: deployment.sku.capacity
    }
    properties: {
      model: {
        format: deployment.model.format
        name: deployment.model.name
        version: deployment.model.version
      }
    }
}]

@description('Create an App Configuration key-value pair for the Azure OpenAI in AI Foundry account endpoint.')
resource appConfigOpenApiName 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' =  if (!empty(appConfigName)) {
  parent: appConfig
  name: 'openai-endpoint'
  properties: {
    value: aiFoundryAccount.properties.endpoints['OpenAI Language Model Instance API']
    contentType: 'text/plain'
    tags: {
      environment: 'production'
    }
  }
}

@description('Create a secret in the Key Vault with the Azure OpenAI in AI Foundry key.')
resource apiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = if (!empty(keyVaultName)) {
  name: 'openai-apikey'
  parent: keyVault
  tags: tags
  properties: {
    value: aiFoundryAccount.listKeys().key1
  }
}

@description('Create an App Configuration key-value pair for the Azure OpenAI in AI Foundry API key.')
resource appConfigOpenApiKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' =  if (!empty(appConfigName)) {
  parent: appConfig
  name: 'openai-apikey'
  properties: {
    value: '{"uri":"https://${keyVault.name}.vault.azure.net/secrets/openai-apikey"}'
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
    tags: {
      environment: 'production'
    }
  }
}

// *****************************************************************************
// Get built-in roles definititions.
// *****************************************************************************
@description('Create role definition for the Azure AI Developer role')
resource aiDeveloperRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: '64702f94-c441-49e6-a78b-ef80e0188fee' // Azure AI Developer role id
  scope: resourceGroup()
}

@description('Create role definition for the Cognitive Services OpenAI Contributor role')
resource openAiContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a001fd3d-188f-4b5d-821b-7da978bf7442' // Cognitive Services OpenAI Contributor role id
  scope: resourceGroup()
}

@description('Create role definition for the Cognitive Services OpenAI User role')
resource openAiUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' // Cognitive Services OpenAI User role id
  scope: resourceGroup()
}

@description('Create role definition for the Cognitive Services Language Reader role')
resource languageReaderRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7628b7b8-a8b2-4cdc-b46f-e9b35248918e' // Cognitive Services Language Reader role id
  scope: resourceGroup()
}

@description('Assign the Azure AI Developer role to the PostgreSQL server identity on Project.')
resource postgreSqlAiDeveloperRoleAssignmentProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(postgreSqlServerPrincipalId)) {
  name: guid(project.id, postgreSqlServerPrincipalId, aiDeveloperRole.id)
  scope: project
  properties: {
    roleDefinitionId: aiDeveloperRole.id
    principalId: postgreSqlServerPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('Assign the Cognitive Services Language Reader role to the PostgreSQL server on AI Foundry Hub Project.')
resource postgreSqlLanguageReaderRoleAssignmentProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(postgreSqlServerPrincipalId)) {
  name: guid(project.id, postgreSqlServerPrincipalId, languageReaderRole.id)
  scope: project
  properties: {
    roleDefinitionId: languageReaderRole.id
    principalId: postgreSqlServerPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('Assign the Cognitive Services OpenAI User role to the PostgreSQL server on the AI Foundry Hub Project.')
resource postgreSqlCognitiveServicesOpenAiUserRoleAssignmentProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(postgreSqlServerPrincipalId)) {
  name: guid(project.id, postgreSqlServerPrincipalId, openAiUserRole.id)
  scope: project
  properties: {
    roleDefinitionId: openAiUserRole.id
    principalId: postgreSqlServerPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('Assign the Azure AI Developer role to the user running the deployment on the AI Foundry Hub Project.')
resource deployerAiDeveloperRoleAssignmentProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(princialId)) {
  name: guid(project.id, princialId, aiDeveloperRole.id)
  scope: project
  properties: {
    roleDefinitionId: aiDeveloperRole.id
    principalId: princialId
    principalType: 'User'
  }
}

@description('Assign the Cognitive Services Language Reader role to the user running the deployment on AI Foundry Hub Project.')
resource deployerLanguageReaderRoleAssignmentProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(princialId)) {
  name: guid(project.id, princialId, languageReaderRole.id)
  scope: project
  properties: {
    roleDefinitionId: languageReaderRole.id
    principalId: princialId
    principalType: 'User'
  }
}

@description('Assign the Cognitive Services OpenAI Contributor role to the user running the deployment on the AI Foundry Hub Project.')
resource deployerCognitiveServicesOpenAiContributorRoleAssignmentProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(princialId)) {
  name: guid(project.id, princialId, openAiContributorRole.id)
  scope: project
  properties: {
    roleDefinitionId: openAiContributorRole.id
    principalId: princialId
    principalType: 'User'
  }
}

output name string = project.name
output id string = project.id
output aiServicesEndpoint string = aiFoundryAccount.properties.endpoint
output openAiEndpoint string = aiFoundryAccount.properties.endpoints['OpenAI Language Model Instance API']
