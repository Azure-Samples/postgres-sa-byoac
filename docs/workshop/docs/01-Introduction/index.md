# Introduction

This solution accelerator is designed as an end-to-end example of a Financial Services Industry AI-enabled application. It demonstrates the implementation of generative AI capabilities to enhance an existing application with AI-driven data validation, vector search, semantic ranking, and GraphRAG on Azure Database for PostgreSQL, and illustrates how they can be combined to deliver high quality responses to financial questions via an intelligent copilot. The app uses a small sample dataset made up of statements of work (SOWs) and invoices. The source code for the accelerator is provided in the following repo: <https://aka.ms/pg-byoac-repo/>.

The application has the following architecture:

![High-level architecture diagram for the solution](../img/solution-architecture-diagram.png)

## Bringing your own data to the solution

This solution accelerator is structured to use sample vendor, SOW, and invoice data, which has been provided for demonstration purposes. However, if you want to use it with your own data or augment an existing solution, you will need to modify certain steps. Where applicable, notes are provided to indicate key areas where adjustments may be necessary to integrate custom datasets.

## Learning Objectives

The goal of the solution accelerator is to teach you to how to **add rich AI capabilities** using Azure Database for PostgreSQL and Azure AI Services to your existing applications. You will gain hands-on experience integrating advanced AI validation during data ingestion to ensure financial documents, like invoices, align with their associated statement of work. By leveraging Azure OpenAI for robust data validation and Azure Document Intelligence for comprehensive extraction and analysis, you will improve data quality. By adding a copilot chat feature, you will provide the ability for users to gain deep insights into vendors' invoicing accuracy, timeliness, and quality. This comprehensive approach equips you with the skills to seamlessly enrich your existing applications with AI-enhanced features, boosting their performance and reliability in the financial services industry.

By completing the solution accelerator, you will learn to:

- Use Azure AI Services to automate data validation tasks during ingestion to streamline workflows.
- Integrate Generative AI capabilities into your Azure Database for PostgreSQL-based applications using the [Azure AI extension](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-integrate-azure-ai).
- Use the [Retrieval Augmented Generation (RAG) pattern](https://learn.microsoft.com/azure/ai-studio/concepts/retrieval-augmented-generation) in a copilot <br/> (to ground responses in your own data).
- Use [Azure Container Apps](https://aka.ms/azcontainerapps) for deployment <br/> (to get hosted UI and API apps for real-world use).
- Use [Azure Developer CLI](https://aka.ms/azd) with AI Application Templates <br/> (to provision & deploy apps consistently across teams)

## Learning Resources

1. **Azure Database for PostgreSQL - Flexible Server** | [Overview](https://learn.microsoft.com/azure/postgresql/flexible-server/service-overview)
2. **Generative AI with Azure Database for PostgreSQL - Flexible Server** | [Overview](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-overview)
3. **Azure AI extension for PostreSQL** | [How to integrate Azure AI](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-azure-overview)
4. **Azure AI Foundry**  | [Documentation](https://learn.microsoft.com/azure/ai-studio/) · [Architecture](https://learn.microsoft.com/azure/ai-studio/concepts/architecture) · [SDKs](https://learn.microsoft.com/azure/ai-studio/how-to/develop/sdk-overview) ·  [Evaluation](https://learn.microsoft.com/azure/ai-studio/how-to/evaluate-generative-ai-app)
5. **Azure Container Apps**  | [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/) · [Deploy from code](https://learn.microsoft.com/azure/container-apps/quickstart-repo-to-cloud?tabs=bash%2Ccsharp&pivots=with-dockerfile)
6. **Responsible AI**  | [Overview](https://www.microsoft.com/ai/responsible-ai) · [With AI Services](https://learn.microsoft.com/azure/ai-services/responsible-use-of-ai-overview?context=%2Fazure%2Fai-studio%2Fcontext%2Fcontext) · [Azure AI Content Safety](https://learn.microsoft.com/azure/ai-services/content-safety/)
