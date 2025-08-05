// *****************************************************************************
// Bicep module to create an Azure Database for PostgreSQL - Flexible Server.
// *****************************************************************************
@description('The name of the PostgreSQL server.')
param serverName string

@description('The location of the PostgreSQL server.')
param location string

@description('The SKU name for the PostgreSQL server.')
param skuName string = 'Standard_D2ds_v4'

@description('The tier for the PostgreSQL server.')
@allowed([
  'GeneralPurpose'
  'MemoryOptimized'
  'Burstable'
])
param skuTier string = 'GeneralPurpose'

@description('The version of the PostgreSQL server.')
param version string = '16'

@description('Azure database for PostgreSQL storage Size ')
param storageSizeGB int = 32

@description('PostgreSQL Server backup retention days')
param backupRetentionDays int = 7

@description('Geo-Redundant Backup setting')
param geoRedundantBackup string = 'Disabled'

@description('The tags to apply to the resources.')
param tags object

@description('The name of the app config to store the connection string.')
param appConfigName string

@description('The subnet ID for the PostgreSQL server.')
param subnetId string = ''

@description('Name for DNS Private Zone when connecting to Subnet')
param dnsZoneName string = serverName

@description('Fully Qualified DNS Private Zone')
param dnsZoneFqdn string = '${dnsZoneName}.postgres.database.azure.com'

@description('The name of the storage account to assign an access policy.')
param storageAccountName string

@description('High Availability Mode')
@allowed([
  'ZoneRedundant'
  'Disabled'
])
param highAvailabilityMode string = 'Disabled'

var connectSubnet = !empty(subnetId)

@description('Gets a reference to the shared Azure Storage account.')
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = if (!empty(storageAccountName)) {
  name: storageAccountName
}

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (connectSubnet) {
  name: dnsZoneFqdn
  location: 'global'
}

@description('Creates a PostgreSQL Flexible Server.')
resource postgreSqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2025-01-01-preview' = {
  name: serverName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: subscription().tenantId
    }
    storage: {
      storageSizeGB: storageSizeGB  
    }
    createMode: 'Default'
    version: version
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    highAvailability: {
      mode: highAvailabilityMode
    }
    network: connectSubnet ?{
      delegatedSubnetResourceId: subnetId
      privateDnsZoneArmResourceId: dnsZone.id
      publicNetworkAccess: 'Enabled'
    } : {
      publicNetworkAccess: 'Enabled'
    }
  }
}

@description('Creates a firewall rule to allow access from all Azure services and IP addresses.')
resource firewallRuleAllowAzureIPs 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2025-01-01-preview' = {
  parent: postgreSqlServer
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2024-05-01' existing = if (!empty(appConfigName)) {
  name: appConfigName
}

resource appConfigPostgresqlServerName 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = if (!empty(appConfigName)) {
  parent: appConfig
  name: 'postgresql-server'
  properties: {
    value: postgreSqlServer.properties.fullyQualifiedDomainName
  }
}

@description('Assigns the Storage Blob Data Contributor role to the PostgreSQL server identity to provide access to blobs in the storage account.')
resource storageBlobDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(storage.id, postgreSqlServer.id, 'StorageBlobDataContributorRole')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor role
    principalId: postgreSqlServer.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output name string = postgreSqlServer.name
output fqdn string = postgreSqlServer.properties.fullyQualifiedDomainName
output principalId string = postgreSqlServer.identity.principalId
