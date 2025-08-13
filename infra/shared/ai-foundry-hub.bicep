// *****************************************************************************
// Bicep module to create a Hub within Azure AI Foundry.
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

@description('The name to assign to the AI Foundry Hub.')
param hubName string = 'hub-${uniqueString(resourceGroup().id)}'

@description('The friendly name for the AI Foundry Hub.')
param hubFriendlyName string = 'AI Foundry Hub'

@description('The description for the AI Foundry Hub.')
param hubDescription string = 'AI Foundry Hub for shared AI resources'

@description('Tags to apply to the Azure AI Foundry resources.')
param tags object = {}

// Dependency parameters
param applicationInsightsName string
param keyVaultName string
param containerRegistryName string
param storageAccountName string

// *****************************************************************************
// Get references to required dependencies for the AI Foundry Hub
// *****************************************************************************
// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}
// Container registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}
// Key vault
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}
// Storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

@description('Create an AI Foundry Hub.')
resource hub 'Microsoft.MachineLearningServices/workspaces@2025-07-01-preview' = {
  name: hubName
  location: location
  tags: tags
  kind: 'Hub'
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // Hub properties
    friendlyName: hubFriendlyName
    description: hubDescription
    managedNetwork: {
      isolationMode: 'Disabled'
    }
    enableDataIsolation: true
    systemDatastoresAuthMode: 'identity'
    // Attach dependent resources
    keyVault: keyVault.id
    storageAccount: storageAccount.id
    applicationInsights: applicationInsights.id
    containerRegistry: containerRegistry.id
  }
}

output name string = hub.name
