// *****************************************************************************
// Bicep module to create a new Container Apps Environment.
// *****************************************************************************

@description('The name of the Container Apps Environment.')
param name string

@description('The location for the Container Apps Environment.')
param location string = resourceGroup().location

@description('Tags to apply to the Container Apps Environment.')
param tags object = {}

// Dependency parameters
@description('The name of the Log Analytics Workspace to use for logging.')
param logAnalyticsWorkspaceName string
@description('The name of the Application Insights resource to use for monitoring.')
param applicationInsightsName string = ''

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    daprAIConnectionString: applicationInsights.properties.ConnectionString
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

output name string = containerAppsEnvironment.name
output domain string = containerAppsEnvironment.properties.defaultDomain
