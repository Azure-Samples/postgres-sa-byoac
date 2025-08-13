// *****************************************************************************
// Bicep module to create a new Azure App Configuration store.
// *****************************************************************************

@description('The name of the App Configuration store.')
param name string

@description('The location for the App Configuration store.')
param location string = resourceGroup().location

@description('Tags to apply to the App Configuration store.')
param tags object = {}

// Dependency parameters
@description('The name of the Key Vault to assign an access policies.')
param keyVaultName string = ''

@description('The principal ID of the user to assign the App Configuration Data Owner role to')
param principalId string = deployer().objectId
param principalType string = 'User'

@allowed([
  'Enabled', 'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@allowed([
  'Standard', 'Free'
])
param skuName string = 'Standard'

@description('Creates a new Azure App Configuration store.')
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2025-02-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: skuName
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    dataPlaneProxy: {
      authenticationMode: 'Pass-through'
    }
  }
  tags: tags
}

@description('Assign the App Configuration Data Owner role to principalId passed in for the user running the deployment.')
resource appConfigRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (!empty(principalId)) {
  name: guid(subscription().id, resourceGroup().id, principalId, 'AppConfigDataOwner')
  scope: appConfig
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b') // App Configuration Data Owner role
    principalId: principalId
    principalType: principalType
  }
}

@description('Retrieves a reference to the shared key vault.')
resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = if (!empty(keyVaultName)) {
  name: keyVaultName
}

@description('Assigns the Key Vault Secrets User role to the App Configuration store identity.')
resource keyVaultSecretUserRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (!empty(keyVaultName)) {
  name: guid(subscription().id, resourceGroup().id, keyVault.id, 'KeyVaultSecretsUser')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User role
    principalId: appConfig.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

@description('Creates an access policy in the Key Vault for the App Configuration store.')
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = if (!empty(keyVaultName)) {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        objectId: appConfig.identity.principalId
        permissions: {
          secrets: ['get', 'list']
        }
        tenantId: subscription().tenantId
      }
    ]
  }
  dependsOn: [
    appConfigRoleAssignment
    keyVaultSecretUserRole
  ]
}

output name string = appConfig.name
output endpoint string = appConfig.properties.endpoint
