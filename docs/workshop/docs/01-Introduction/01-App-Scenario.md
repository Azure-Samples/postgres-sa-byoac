# 1.1 The App Scenario

## Streamlining Contract Validation in Financial Services

In the financial services industry, validating contract-related documents such as Statements of Work (SOWs) and invoices presents unique challenges. Ensuring that invoices align with SOWs, especially for milestone-based payments and specific deliverables, can be a meticulous and error-prone process. Traditionally, this validation involves manual comparison and cross-checking, often leading to delays, errors, and increased operational costs. This accelerator offers a solution that leverages Azure Database for PostgreSQL - Flexible Server and Azure AI Foundry's comprehensive suite of AI models and services to automate and streamline this process, resulting in faster, more accurate, and cost-effective invoice validation.

The accelerator is designed to demonstrate how an existing financial services application can be enhanced by integrating advanced AI capabilities into Azure Database for PostgreSQL through the Azure AI extension and incorporating Azure OpenAI's GPT-4o model to validate and review contract-related documents.

??? question "Using your own data?"

    While the provided scenario utilizes pre-configured vendor, SOW, and invoice data, the framework is designed to be adaptable. You can replace these with your own datasets to better align with your specific business needs. Key steps where adjustments may be required have been highlighted throughout the guide.

## Getting Started with the Woodgrove Bank Application

You have been provided starter code and deployment scripts for the _Woodgrove Bank_ web application. This application comprises an enterprise user portal integrated with a custom backend API. You will enhance this application by integrating Azure AI services throughout this accelerator. Key steps include:

1. **Integrating Generative AI (GenAI) Capabilities into Azure Database for PostgreSQL**: Use the Azure AI (`azure_ai`) and pgvector (`vector`) extensions to enhance your PostgreSQL database with advanced GenAI and vector search capabilities.
2. **Automating Data Validation with AI**: Enhance the data ingestion process with automated, AI-driven validation using Azure Document Intelligence and Azure AI services.
3. **Building a Copilot**: Create an intelligent assistant using Azure AI Foundry and Azure Database for PostgreSQL - Flexible Server, incorporating the Retrieval Augmented Generation (RAG) design pattern to ensure its responses are based on the private data maintained by the enterprise.
4. **Enhance RAG precision**: Use the Azure AI (`azure_ai`) extension's `rank` semantic operator to intelligently rerank retrieved results based on their relevance to the user query, boosting both the accuracy and contextual alignment of responses generated from RAG context retrieved from the database.
5. **Adding GraphRAG functionality**: Install the Apache AGE (`age`) extension to allow your PostgreSQL database to be used as a graph database, providing a comprehensive solution for analyzing interconnected data.

This solution accelerator aims to teach you how to integrate AI capabilities into an existing application by leveraging Microsoft Azure's AI services to automate and streamline the validation of contract-related documents in the financial services industry. This integration results in faster, more accurate, and cost-effective processes. Additionally, the copilot will provide intelligent assistance, enabling users to gain actionable insights from data stored in the Azure Database for PostgreSQL, enhancing their overall experience.
