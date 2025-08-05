// *****************************************************************************
// Bicep module to create a serverless endpoint for the rerank model deployed in
// the Azure Machine Learning workspace.
// *****************************************************************************

@description('The name of the Azure Machine Learning workspace where the rerank model and serverless endpoint will be created.')
param workspaceName string

@description('The location of the Azure Machine Learning workspace where the rerank model and endpoint will be deployed.')
param location string

@description('The id of the model for which a subscription and endpoint are being created.')
param modelId string

@description('Tags for the endpoint resource.')
param tags object = {}

@description('The name of the model.')
var modelName = toLower(replace(substring(modelId, lastIndexOf(modelId, '/') + 1), '.', '-'))

@description('The Azure Machine Learning project where the model subscription and endpoint will be created.')
resource project 'Microsoft.MachineLearningServices/workspaces@2025-07-01-preview' existing = {
  name: workspaceName
}

@description('Creates a serverless endpoint for the rerank model.')
resource rerankEndpoint 'Microsoft.MachineLearningServices/workspaces/serverlessEndpoints@2025-07-01-preview' = {
  parent: project
  name: '${modelName}-endpoint-${uniqueString(resourceGroup().id)}'
  location: location
  tags: tags
  kind: 'Serverless'
  sku: {
    name: 'Consumption'
  }
  properties: {
    authMode: 'KeyAndAAD'
    modelSettings: {
      modelId: modelId
    }
  }
}

output inferenceEndpoint string = rerankEndpoint.properties.inferenceEndpoint.uri
