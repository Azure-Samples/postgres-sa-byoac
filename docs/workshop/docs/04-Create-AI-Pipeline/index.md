# AI-driven Data Validation

## Building an AI-Enhanced Data Ingestion and Processing Pipeline

An end-to-end AI-powered data pipeline has been provided to automate Invoice Pilot's data ingestion and validation process. This pipeline starts when documents are uploaded to Azure Blob Storage and employs Azure AI services for intelligent ingestion, automated validation, semantic analysis, and optimized storage.

Before integrating AI into the data ingestion workflow, the application required manual parsing and input of invoice and SOW data into the application. This process was a time-consuming and labor-intensive process.

This section will review the code that integrates AI components into the solution.

## Validate Documents

AI-driven Data Validation offers a transformative solution by automating document processing, improving accuracy, and reducing the burden on human reviewers. Through a combination of intelligent document ingestion, machine learning, and natural language processing, AI will revolutionize contract validation.

The document ingestion workflow performs document text extraction, validation on document parts, comparison of milestone pricing with invoiced amounts and work performed, and looking for key SOW components such as compliance sections and wording. It includes the following steps:

1. Azure AI Document Intelligence performs text extraction and uses Azure OpenAI to generate text embeddings of document chunks/sections inserted into the database.

2. The `pgvector` extension in Azure Database for PostgreSQL performs semantic similarity comparisons between key document sections. Azure OpenAI's GPT-4o model is leveraged for data analysis and vector similarity evaluation. A threshold similarity score is assigned to assess the similarity of document wording and to validate that documents contain appropriate language.

???+ info "Document validation worker process architecture"

    The best practice for enterprise systems is to build a background worker process that performs the document validation workflow. When a document is uploaded, a message is sent using a queue, like Event Grid, which is then handled by the background worker process to perform the document ingestion and validation workflow.

    To make this guide easier to follow, the document validation workflow has been implemented as REST API methods called directly by the front-end application. The following sections will guide you through reviewing the AI integration code into the application.
