// *****************************************************************************
// Bicep module to create a marketplace subscription for a reranking model in an
// Azure Machine Learning workspace.
// *****************************************************************************
@description('The name of the Azure Machine Learning workspace where the rerank model will be created.')
param workspaceName string

@description('The id of the model for which a subscription is being created.')
param modelId string = 'azureml://registries/azureml-cohere/models/Cohere-rerank-v3.5'

@description('The name of the model.')
var modelName = toLower(replace(substring(modelId, lastIndexOf(modelId, '/') + 1), '.', '-'))
@description('Hash of the model id to ensure unique naming.')
var modelHash = uniqueString(modelId)

@description('The Azure Machine Learning project where the model subscription will be created.')
resource workspace 'Microsoft.MachineLearningServices/workspaces@2025-07-01-preview' existing = {
  name: workspaceName
}

@description('Creates a marketplace subscription for the rerank model.')
resource modelSubscription 'Microsoft.MachineLearningServices/workspaces/marketplaceSubscriptions@2025-07-01-preview' = {
  name: '${modelName}-${modelHash}'
  parent: workspace
  properties: {
    modelId: modelId
  }
}

output name string = modelSubscription.name
