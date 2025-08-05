// *****************************************************************************
// Bicep module to create an Azure Storage account.
// *****************************************************************************

param containers array = []
param files array = []
param appConfigName string
param location string = resourceGroup().location
param name string
param tags object = {}
param principalId string
param principalType string = 'User'

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storage
  name: 'default'
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [
  for container in containers: {
    parent: blobService
    name: container.name
  }
]

resource blobFiles 'Microsoft.Resources/deploymentScripts@2020-10-01' = [
  for file in files: {
    name: file.file
    location: location
    kind: 'AzureCLI'
    properties: {
      azCliVersion: '2.26.1'
      timeout: 'PT5M'
      retentionInterval: 'PT1H'
      environmentVariables: [
        {
          name: 'AZURE_STORAGE_ACCOUNT'
          value: storage.name
        }
        {
          name: 'AZURE_STORAGE_KEY'
          secureValue: storage.listKeys().keys[0].value
        }
      ]
      scriptContent: 'echo "${file.content}" > ${file.file} && az storage blob upload -f ${file.file} -c ${file.container} -n ${file.path}'
    }
    dependsOn: [ blobContainers ]
  }
]

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2025-02-01-preview' existing = if (!empty(appConfigName)) {
  name: appConfigName
}

resource appConfigStorageAccountName 'Microsoft.AppConfiguration/configurationStores/keyValues@2025-02-01-preview' = if (!empty(appConfigName)) {
  parent: appConfig
  name: 'storage-account'
  properties: {
    value: storage.name
  }
}

resource storageBlobDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(storage.id, principalId, 'StorageBlobDataContributorRole')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor role
    principalId: principalId
    principalType: principalType
  }
}

output name string = storage.name
output id string = storage.id
