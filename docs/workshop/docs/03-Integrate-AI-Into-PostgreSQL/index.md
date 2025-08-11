# Integrate Generative AI into Azure Database for PostgreSQL - Flexible Server

??? question "Using your own data?"

    To accommodate attendees who wish to integrate their own PostgreSQL databases into the solution accelerator, the following steps are recommended:
    
    **1. Install Necessary Extensions**
    Ensure your PostgreSQL database has the required extensions installed:
    
    azure_ai: Facilitates integration with Azure AI services.
    pgvector: Enables vector data storage and similarity searches.
    pg_diskann: Provides efficient vector indexing and searching capabilities.

    *Note: The pg_diskann extension depends on the vector extension; ensure both are installed.*

    **2. Identify and Modify Relevant Tables**
    Determine which tables in your existing database will store AI-generated data. For these tables:
    
    - Add Vector Columns: Introduce columns of type vector to store embeddings.
    Example:
    ``` sql
      ALTER TABLE your_table
      ADD COLUMN embedding vector(1536); -- Adjust dimension as needed for your model
    ```
    - Create DiskANN Indexes: Enhance query performance by indexing the vector columns.
    Example:
    ```sql
      CREATE INDEX your_table_embedding_diskann_idx
      ON your_table
      USING diskann (embedding vector_cosine_ops);
    ```

    **3. Configure Managed Identity and Permissions**
    Configure the following Azure services:

    - Managed Identity: Assign a managed identity to your PostgreSQL server if not already done.
    - Role Assignment: Grant the managed identity the Storage Blob Data Contributor role on the relevant Azure Storage account to permit necessary data access.
    
    By implementing these steps, you can seamlessly integrate your existing PostgreSQL databases into the solution accelerator, enabling efficient AI-driven data processing and analysis.

Generative AI (GenAI) represents a cutting-edge class of AI algorithms designed to create new, original content based on patterns and data learned from existing information. Natural language processing (NLP) is a key part of this. NLP allows generative AI to understand and produce human language, making it capable of tasks like summarizing large blocks of text, translating languages, or conversing with people. Using NLP, generative AI can create content that sounds natural and makes sense in context. By employing techniques like prompting and retrieval augmented generation (RAG), GenAI can produce innovative outputs, such as text, images, and more.

Incorporating Generative AI (GenAI) within Azure Database for PostgreSQL - Flexible Server is accomplished through the Azure AI (`azure_ai`) and pgvector (`vector`) extensions. The `azure_ai` extension enables the integration of large language models (LLMs) directly within your database, providing seamless interaction with Azure's advanced AI services, such as Azure OpenAI and Azure Cognitive Services. With these integrations, you can elevate your applications by embedding robust AI functionalities directly into your database infrastructure. The `vector` extension works with the `azure_ai` extension, allowing vector embeddings to be generated in database queries, then stored and queried in the database. It also enables powerful vector similarity search capabilities.

In addition, the `pg_diskann` extension enables DiskANN support for efficient vector indexing and searching. DiskANN is a scalable approximate nearest neighbor search algorithm for efficient vector search at any scale. It offers high recall, high queries per second, and low query latency, even for billion-point datasets.

In this section, you will use extensions to enhance your PostgreSQL database with Generative AI and Vector Search capabilities. Here's what you will accomplish:

- [ ] Install the `azure_ai`, `pg_diskann`, and `vector` extensions on your PostgreSQL database
- [ ] Configure the `azure_ai` extension with the connection details for your Azure AI Foundry services
- [ ] Add vector columns to database tables to allow embeddings to be stored alongside text data
- [ ] Improve vector query performance with DiskANN
- [ ] Generate and store embeddings for existing data

Following these steps will transform your PostgreSQL database into a powerful AI-enhanced platform capable of executing advanced generative AI tasks and providing deeper insights from your data.
