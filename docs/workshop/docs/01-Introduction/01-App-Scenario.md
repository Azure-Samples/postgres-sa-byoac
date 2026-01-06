# 1.1 The App Scenario

## Streamlining Contract Validation in Financial Services

In the financial services industry, validating contract-related documents such as Statements of Work (SOWs) and invoices presents unique challenges. Ensuring that invoices align with SOWs, especially for milestone-based payments and specific deliverables, can be a meticulous and error-prone process. Traditionally, this validation involves manual comparison and cross-checking, often leading to delays, errors, and increased operational costs. This accelerator offers a solution that leverages Azure Database for PostgreSQL - Flexible Server and Azure's comprehensive suite of AI services to automate and streamline this process, resulting in faster, more accurate, and cost-effective invoice validation.

**Invoice Pilot** demonstrates how this challenge can be addressed using Azure technologies. The solution leverages **Azure Database for PostgreSQL – Flexible Server** along with **Azure’s AI capabilities** to automate and streamline contract validation. By combining database extensions, AI services, and generative AI models, the accelerator delivers faster, more accurate, and cost-effective invoice verification workflows.

This reference implementation shows how a financial services organization can integrate advanced AI capabilities into their existing application by using:

- **Azure AI Extension** and **pgvector** to enable AI functions and vector search directly inside PostgreSQL.  
- **Azure Document Intelligence** to extract and validate key information from uploaded invoices and SOWs.  
- **Azure OpenAI (GPT-4)** to reason over extracted data and verify alignment between documents.  
- **Apache AGE** to add graph analytics capabilities for exploring relationships among vendors, SOWs, and invoices.

??? question "Using your own data?"

    While the provided scenario utilizes pre-configured vendor, SOW, and invoice data, the framework is designed to be adaptable.
    You can replace these with your own datasets to better align with your specific business needs.
    Key steps where adjustments may be required have been highlighted throughout the guide.

## Getting Started with Invoice Pilot

The **Invoice Pilot** application is fully implemented and ready to deploy. It includes:

- A **Web Application** that serves as an enterprise portal for uploading and reviewing invoices.  
- A **Backend API** integrated with Azure Database for PostgreSQL and Azure AI services.  
- A **Set of Automation Pipelines** that handle document ingestion, validation, and AI-based reasoning.

Once deployed, you can explore the following key capabilities:

1. **Integrated Generative AI in PostgreSQL**  
   The solution uses the Azure AI (`azure_ai`) and pgvector (`vector`) extensions to enable semantic reasoning and vector similarity search inside the database.  

2. **Automated Data Validation**  
   The system automatically validates invoices using Azure Document Intelligence for extraction and Azure AI for semantic matching against corresponding SOWs.  

3. **Copilot Experience**  
   A built-in conversational assistant, powered by Azure OpenAI and the PostgreSQL database, provides contextual answers based on enterprise data through Retrieval-Augmented Generation (RAG).  

4. **Graph-Based Insights**  
   With the Apache AGE (`age`) extension, the database can perform graph queries to reveal relationships between projects, vendors, and contracts.

5. **Flexible AI Framework Support**  
   The application supports two popular AI frameworks: **AgentFramework** and **LangChain**. The application can be configured to use either of these frameworks based on your preference. Detailed configuration steps for both deployment and local development are covered later in this guide.

This solution accelerator serves as a **guide** to understanding how AI-powered data processing, retrieval, and reasoning can be integrated into enterprise systems using Azure's AI and database ecosystem.
By the end of this guide, you’ll have a complete understanding of the architecture, deployment flow, and design principles behind Invoice Pilot—without needing to modify or build any components yourself.
