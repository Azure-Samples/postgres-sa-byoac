// *****************************************************************************
// Bicep module to create an administrator account on an
// Azure Database for PostgreSQL - Flexible Server.
// *****************************************************************************
param postgreSqlServerName string
param principalName string
param principalId string
param principalType string = 'ServicePrincipal'
param principalTenantId string = subscription().tenantId

@description('Gets a reference to the existing PostgreSQL Flexible Server resource.')
resource postgreSqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2025-01-01-preview' existing = {
  name: postgreSqlServerName
}

@description('Creates an administrator account for the PostgreSQL Flexible Server.')
resource aadAdmin 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2025-01-01-preview' = {
  parent: postgreSqlServer
  name: principalId
  properties: {
    principalName: principalName
    principalType: principalType
    tenantId: principalTenantId
  }
}
