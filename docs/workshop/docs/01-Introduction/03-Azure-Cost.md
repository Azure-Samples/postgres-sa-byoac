# 1.3 Azure Cost Estimate

The Microsoft Azure resources you deploy will be provisioned within your Azure Subscription. You are responsible for the cost of those services. The cost of the solution will vary depending on the Azure region selected and which deployment options you choose.

Here's a breakout of the _estimated cost_ of Azure resources deployed for this solution:

- Azure Database for PostgreSQL: ~$0.90/day
- Azure App Configuration: ~$0.02/day
- Azure Container Registry: ~$0.17/day
- Azure OpenAI in Azure AI Foundry: Dependent upon usage of Copilot, AI-validation, and number of documents processed in the solution.
- Azure AI Foundry Services Rerank Model (`cohere-rerank-v3.5`): Dependent upon usage of Copilot, and number of [queries](https://learn.microsoft.com/azure/ai-foundry/concepts/models-inference-examples#pricing-for-cohere-rerank-models) processed in the solution.
- Other services are minimal cost.

The estimated monthly cost is ~$33.80.

!!! warning "The above costs are only estimates."

    The costs provided here are estimates based on running the solution accelerator using the provided configuration and are intended to provide general guidance about the costs associated with running the solution accelerator. Depending on deployment options, region selection, Azure OpenAI token usage, rerank model queries, and data sizes, individual costs will vary.
