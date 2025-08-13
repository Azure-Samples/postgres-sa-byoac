// *****************************************************************************
// Bicep module to create a database on an existing PostgreSQL Flexible Server.
// *****************************************************************************

@description('The name of the PostgreSQL server.')
param serverName string
@description('The name of the database to create.')
param databaseName string
@description('The character set for the database.')
param charset string = 'UTF8'
@description('The collation for the database.')
param collation string = 'en_US.utf8'
@description('The name of the App Configuration store to store the database name.')
param appConfigName string

@description('Gets a reference to the Azure PostgreSQL Flexible Server resource.')
resource postgresqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2025-01-01-preview' existing = {
  name: serverName
}

resource postgresqlDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2025-01-01-preview' = {
  name: databaseName
  parent: postgresqlServer
  properties: {
    charset: charset
    collation: collation
  }
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2024-05-01' existing = if (!empty(appConfigName)) {
  name: appConfigName
}

resource appConfigPostgresqlDatabaseName 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = if (!empty(appConfigName)) {
  parent: appConfig
  name: 'postgresql-database'
  properties: {
    value: postgresqlDatabase.name
  }
}

output name string = postgresqlDatabase.name
