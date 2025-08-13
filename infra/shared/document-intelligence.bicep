@description('The location of the Document Intelligence resource.')
param location string

@description('The name of the Document Intelligence resource.')
param name string

@description('The SKU of the Document Intelligence resource.')
param skuName string = 'F0'

@description('Tags to apply to the resource.')
param tags object = {}

@description('The name of the Key Vault to store secrets in.')
param keyVaultName string = ''

var keySecretName = 'doc-intelligence-key'

resource documentIntelligence 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: 'FormRecognizer'
  identity: {
    type: 'None'
  }
  properties: {
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
  }
}

@description('Retrieves a reference to the shared key vault.')
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = if (!empty(keyVaultName)) {
  name: keyVaultName
}

@description('Creates a secret in the Key Vault with the Document Intelligence key.')
resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: keySecretName
  properties: {
    value: listKeys(documentIntelligence.id, '2024-10-01').key1
  }
}

output name string = documentIntelligence.name
output formRecognizerEndpoint string = documentIntelligence.properties.endpoints.FormRecognizer
output keySecretName string = keySecretName
