# PostgreSQL Solution Accelerator: Build your own advanced AI Copilot with Postgres

This solution accelerator is designed as an end-to-end example of an AI-enabled application built on Azure Postgres. It demonstrates the implementation of generative AI capabilities to enhance an existing application with AI-driven data validation, vector search, DiskANN, semantic re-ranking, LangChain agent/tools framework, and GraphRAG on Azure Database for PostgreSQL, and illustrates how they can be combined to deliver high quality responses to financial questions via an intelligent copilot. The app uses a small sample dataset made up of statements of work (SOWs) and invoices.

> The full documentation for deploying and completing the workshop can be found here:
> <https://aka.ms/pg-byoac-docs/>

## Solution Accelerator Architecture

![High-level architecture diagram for the solution](docs/workshop/docs/img/solution-architecture-diagram.png)

## Key Highlights

1. **LangChain Agent and Tool Framework:** Demonstrates how to build powerful LangChain-based Agents that interact with PostgreSQL and vector stores using Tools and Chains—bridging LLMs with data and application logic.
2. **Vector Search with RAG Pattern Built into PostgreSQL:** The solution enables in-database Retrieval-Augmented Generation (RAG) using the `pgvector` extension for efficient vector search, making PostgreSQL a powerful foundation for intelligent applications that combine structured data with generative AI.
3. **Semantic Re-ranking with Cross Encoder Model:** Enhances relevance ranking through semantic re-ranking, using the [Cohere Rerank 3.5 model](https://ai.azure.com/explore/models/Cohere-rerank-v3.5/version/3/registry/azureml-cohere).
4. **GraphRAG with Apache AGE for Knowledge-Rich Context:** Extends RAG with GraphRAG, integrating `Apache AGE` (A Graph Extension for PostgreSQL) to enrich retrieval and grounding via knowledge graphs—ideal for complex relationships and semantic context.
5. **High-Performance DiskANN Index Integration:** Supports `DiskANN` (Disk-Accelerated Approximate Nearest Neighbor), offering scalable and fast vector similarity search, optimized for large datasets and low-latency retrieval directly within PostgreSQL.
6. **Azure AI Extension for PostgreSQL:** Leverages the Azure AI Extension, enabling direct embedding generation and model inference from Azure OpenAI in Azure AI Foundry or custom endpoints, eliminating the need for external model integration pipelines.
7. **Azure Storage Extension for Document-Linked Workflows:** Uses the Azure Storage Extension for PostgreSQL to access and retrieve unstructured content such as .csv and documents from Blob Storage directly inside PostgreSQL workflows.
8. **Document Intelligence Integration:** Integrates Azure Document Intelligence (formerly Form Recognizer) to extract structured content from documents—powering advanced data ingestion and enrichment scenarios for AI pipelines.
9. **Hands-On Learning Through Guided Labs:** The solution includes a comprehensive step-by-step hands-on guide with real-world examples—making it ideal for practitioners to learn by doing and gain practical experience with AI-native PostgreSQL patterns.
10. **PostgreSQL Extension for Visual Studio Code**: PostgreSQL for Visual Studio Code provides an essential tool for accelerating and simplifying development workflows by empowering developers to connect to PostgreSQL databases, write and execute queries, and manage database objects without leaving the VS Code environment.
