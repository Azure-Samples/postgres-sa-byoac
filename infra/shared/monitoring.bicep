@description('The region where the resources will be deployed.')
param location string = resourceGroup().location
@description('The name of the Log Analytics Workspace.')
param logAnalyticsName string
@description('The name of the Application Insights resource.')
param applicationInsightsName string
@description('Tags to apply to the resources.')
param tags object = {}

@description('Creates a Log Analytics workspace.')
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

@description('Creates an Application Insights resource.')
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

output applicationInsightsName string = applicationInsights.name
output logAnalyticsWorkspaceId string = logAnalytics.id
output logAnalyticsWorkspaceName string = logAnalytics.name
output appInsightsConnectionString string = applicationInsights.properties.ConnectionString
