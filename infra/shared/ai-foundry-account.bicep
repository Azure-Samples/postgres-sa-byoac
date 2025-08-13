// *****************************************************************************
// Bicep module to create an Azure AI Foundry account with a hub and project.
// *****************************************************************************
@description('Location for the Azure AI Foundry resource.')
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

@description('Tags to apply to the Azure AI Foundry resources.')
param tags object = {}

@description('The name to assign to the Azure AI Foundry account.')
param accountName string = 'aif-${uniqueString(resourceGroup().id)}'

@description('The principal Id of the user running the deployment.')
param princialId string = deployer().objectId

@description('The principal Id of the PostgreSQL server to assign security roles.')
param postgreSqlServerPrincipalId string = ''

@description('Create an Azure AI Foundry account.')
resource aiFoundryAccount 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: accountName
  location: location
  tags: tags
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {}
    customSubDomainName: accountName
    disableLocalAuth: false // true = Ensures that the service disables key-based authentication
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    allowProjectManagement: true
    defaultProject: 'DefaultProject'
    associatedProjects: [
      'DefaultProject'
    ]
  }
}

@description('Create the default project in the AI Foundry account.')
resource default_project 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  parent: aiFoundryAccount
  name: 'DefaultProject'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Default project created with the resource'
    displayName: 'Default Project'
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

// *****************************************************************************
// Assign roles to the PostgreSQL server for the AI Foundry account and project.
// *****************************************************************************
@description('Assign the Azure AI Developer role to the PostgreSQL server on the AI Foundry account.')
resource postgreSqlAiDeveloperRoleAssignmentFoundry 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(postgreSqlServerPrincipalId)) {
  name: guid(aiFoundryAccount.id, postgreSqlServerPrincipalId, aiDeveloperRole.id)
  scope: aiFoundryAccount
  properties: {
    roleDefinitionId: aiDeveloperRole.id
    principalId: postgreSqlServerPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('Assign the Cognitive Services Language Reader role to the PostgreSQL server on the AI Foundry account.')
resource postgreSqlLanguageReaderRoleAssignmentFoundry 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(postgreSqlServerPrincipalId)) {
  name: guid(aiFoundryAccount.id, postgreSqlServerPrincipalId, languageReaderRole.id)
  scope: aiFoundryAccount
  properties: {
    roleDefinitionId: languageReaderRole.id
    principalId: postgreSqlServerPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('Assign the Cognitive Services OpenAI User role to the PostgreSQL server on the AI Foundry account.')
resource postgreSqlCognitiveServicesOpenAiUserRoleAssignmentFoundry 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(postgreSqlServerPrincipalId)) {
  name: guid(aiFoundryAccount.id, postgreSqlServerPrincipalId, openAiUserRole.id)
  scope: aiFoundryAccount
  properties: {
    roleDefinitionId: openAiUserRole.id
    principalId: postgreSqlServerPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// *****************************************************************************
// Assign roles to the AI Foundry account and project for the user running the deployment.
// *****************************************************************************
@description('Assign the Azure AI Developer role to the user running the deployment on the AI Foundry account.')
resource deployerAiDeveloperRoleAssignmentFoundry 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(princialId)) {
  name: guid(aiFoundryAccount.id, princialId, aiDeveloperRole.id)
  scope: aiFoundryAccount
  properties: {
    roleDefinitionId: aiDeveloperRole.id
    principalId: princialId
    principalType: 'User'
  }
}

@description('Assign the Cognitive Services Language Reader role to the user running the deployment on the AI Foundry account.')
resource deployerLanguageReaderRoleAssignmentFoundry 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(princialId)) {
  name: guid(aiFoundryAccount.id, princialId, languageReaderRole.id)
  scope: aiFoundryAccount
  properties: {
    roleDefinitionId: languageReaderRole.id
    principalId: princialId
    principalType: 'User'
  }
}

@description('Assign the Cognitive Services OpenAI Contributor role to the user running the deployment on the AI Foundry account.')
resource deployerCognitiveServicesOpenAiContributorRoleAssignmentFoundry 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(princialId)) {
  name: guid(aiFoundryAccount.id, princialId, openAiContributorRole.id)
  scope: aiFoundryAccount
  properties: {
    roleDefinitionId: openAiContributorRole.id
    principalId: princialId
    principalType: 'User'
  }
}

output name string = aiFoundryAccount.name
