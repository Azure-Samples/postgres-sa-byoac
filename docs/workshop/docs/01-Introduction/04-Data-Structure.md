# 1.4 Provided Artifacts

This section provides an overview of the table schema and data artifacts (e.g., SOW documents, invoices, and validation results) used in the solution accelerator. It highlights **key fields** that enable AI-powered processing and explains why specific fields are used by Azure AI services.

??? question "Using your own data?"

    If you are **adapting the accelerator** to use your own data, modifications may be required to align with your existing database schema and data structures.

    1. Map Your Data to the Existing Schema

          - Identify **which of your tables correspond** to `sows`, `invoices`, and `vendors`.  
          - Ensure your **data can be chunked and processed** similarly to `sow_chunks`.
          - Leverage a **JSONB** column to store additional data dynamically while keeping the core table structures unchanged.

    2. Add Vector Embeddings to Enable AI Search

          - Create a **vector column (`embedding`)** in relevant tables to store AI-generated embeddings.  
          - Use **pg_diskann** for efficient AI-powered search.  

    3. Modify AI Processing Scripts

          - Update **data extraction scripts** to reflect your field names.  
          - Ensure AI models **extract the correct entities** based on your schema.  

    4. Update Graph Data Export & Relationships

          - Modify data export scripts to align with **your table structure**.  
          - Ensure **Graph relationships** correctly link entities in your database.  

---

## Understanding the Table Schema

The accelerator processes **Statements of Work (SOWs), invoices, validation results, and extracted entities** using a structured PostgreSQL schema. Below is an overview of the **key tables** and their roles:

### Core Tables & Their Purpose

| **Table**                   | **Description** |
|-----------------------------|-----------------------------------------------------------|
| `vendors`                   | Stores vendor details, linking them to associated SOWs and invoices. |
| `status`                    | Stores various status values that can be used to track the state of different entities within the system. |
| `sows`                      | Contains information on Statements of Work, including terms, parties involved, and deliverables. |
| `sow_chunks`                | Breaks down SOW documents into smaller sections for AI processing. |
| `milestones`                | Tracks contractual milestones extracted from SOWs. |
| `deliverables`              | Details key deliverables as defined in SOWs. |
| `invoices`                  | Contains invoice details, such as amounts, due dates, and associated SOWs. |
| `invoice_line_items`        | Stores individual line items extracted from invoices. |
| `invoice_validation_results`| Stores AI-driven validation for invoice accuracy and discrepancies. |
| `sow_validation_results`    | Stores AI-driven validation results for SOW compliance and consistency. |
| `copilot_chat_sessions`     | Stores information about individual chat sessions. |
| `copilot_chat_session_history` | Stores the history of messages exchanged during a chat session. |

### How These Tables Work Together

1. **SOW documents** are processed and broken into structured chunks.  
2. AI services extract key entities (**vendors, deliverables, milestones**).  
3. The extracted information is validated and stored in **validation tables**.  
4. **Invoices** are linked to **SOWs** for contract compliance checks.  

---

## Key Fields Used in AI Processing

The solution accelerator integrates with **Azure AI services** to extract, validate, and process information. Below are **key fields** that play a role in AI workflows and why they were selected.

### Relational Fields Used in AI Services

| **Field Name**              | **Table**                  | **AI Usage** |
|----------------------------|---------------------------|-------------------------------------------|
| `content`             | `sow_chunks`, `invoices`             | AI processes this field to extract structured data from raw text. |
| `embedding`         | `deliverables`, `sow_chunks`, `invoice_line_items`, `invoice_validation_results`, `sow_validation_results` | Used for vector search and similarity retrieval in **semantic search models**. |
| `due_date`       | `deliverables`, `invoice_line_items`              | AI extracts and can validate deadlines. |
| `amount`            | `invoices`                | AI extracts and detects discrepancies in invoice details. |
|`result`            | `sow_validation_results`, `invoice_validation_results`    |  AI-generated analysis of compliance for documents processed  |
| `validation_passed`        | `sow_validation_results`, `invoice_validation_results` | AI-driven validation result for compliance analysis. |
| `metadata`                 |`invoices`                | JSONB column for storing dynamic, AI-generated insights. |

### Graph Relationships

| **Field Name**              | **Graph**                  | **AI Usage** |
|-------------------------------|---------------------------------|--------------------------------------|
|`vendor_id`,`vendor_name`   |    `vendor_graph`    |    Used to analyze vendor performance and relationships    |
|`sow_id`,`sow_number`       |    `vendor_graph`       |    Used to track and validate Statements of Work (SOWs)    |
|`payment_status`,`invoice_amount`    |    `vendor_graph`    | Used to validate and process invoices, detect discrepancies, and ensure compliance.    |

### Why These Fields Matter

- **Vector Embeddings (`embedding`)** enable **semantic search** by allowing **AI-powered retrieval** of similar SOW clauses, contract terms, and invoices.  
- **Validation Fields (`result`, `validation_passed`)** ensure AI-generated extractions meet business rules.  
- **Graph Relationships within `vendor_graph`** supports **GraphRAG (Retrieval-Augmented Generation)** where chosen fields can be utilized in AI models for analysis related to vendors, contracts, and invoices, as well as enhanced AI accuracy.

---

## Extending the Schema with JSONB

The **JSONB** data type in PostgreSQL provides a powerful way to store and query semi-structured data, making it ideal for AI-driven applications that require flexibility in handling diverse and evolving datasets. AI services often work with rapidly changing schemas, various data formats, and unstructured metadata. **JSONB** enables these services to integrate additional data points without rigid schema modifications, ensuring adaptability and performance at scale.

### Why JSONB is Ideal for AI Services

- **Schema Evolution**: AI applications frequently introduce new features, models, or metadata. JSONB allows for **seamless Schema Modifications** without disrupting the existing relational structure.
- **Handling Unstructured Data**: Many AI workloads ingest **sensor data, user interactions, embeddings, and model predictions** that don’t fit into traditional relational columns.
- **Efficient Indexing and Querying**: JSONB supports **GIN (Generalized Inverted Index)** and **JSONPath queries**, making it fast and efficient to search for nested data.
- **Compact Storage and Faster Retrieval**: Unlike plain JSON, JSONB is **binary-optimized**, reducing overhead in AI pipelines that process large volumes of data.

### Using JSONB for AI-Powered Metadata and Model Outputs

When integrating AI services into a PostgreSQL-backed system, JSONB can be leveraged to store:

- **Inference Results** (e.g., probabilities, classifications, embeddings).
- **Model Metadata** (e.g., hyperparameters, training configurations).
- **Feature Extraction Details** (e.g., NLP tokenized words, vector embeddings).
- **Real-time User Interactions** (e.g., chat history, event tracking).

### Adding Indexes for JSONB Queries

GIN (Generalized Inverted Index) is a type of indexing in PostgreSQL that is optimized for handling complex data types, including JSONB. Since JSONB stores data in a binary format and supports rich querying, GIN indexes make it possible to efficiently search within nested JSONB structures.

**Advantages of GIN:**

- Fast Query Performance: GIN significantly speeds up key-value lookups inside JSONB columns.
- Optimized for Nested Structures: It can efficiently index deeply nested JSON objects and arrays.
- Supports JSONB Operators: PostgreSQL provides powerful operators (@>, ?, ?&, ?|) that are optimized when used with GIN.

### Example Usage

<!-- markdownlint-disable MD046 -->
```sql
ALTER TABLE invoices ADD COLUMN metadata JSONB;

-- Insert data into the JSONB column
UPDATE invoices
SET metadata = '{"additional_info": "value", "extra_field": 123}'
WHERE id = 1;

-- Create a GIN index on the JSONB column
CREATE INDEX idx_invoices_metadata ON invoices USING GIN (metadata);

-- Query the record based on one of the JSONB elements
SELECT * FROM invoices
WHERE metadata @> '{"extra_field": 123}';
```

!!! note "The `@>` operator checks if model_output contains the specified JSON key-value pair."

By leveraging JSONB, AI services can store, retrieve, and evolve their data structures efficiently. This approach ensures that new AI-driven insights, feature extraction, and model outputs can be incorporated into the system without rigid schema modifications, ultimately accelerating the deployment and scaling of AI solutions within PostgreSQL environments.

### JSONB Learning Resources

- [Overview of AI Services and Data](https://techcommunity.microsoft.com/blog/adforpostgresql/azure-postgresql-with-azure-open-ai-to-innovate-banking-apps-unlocking-the-power/4257561)
- [PostgreSQL JSONB Documentation](https://www.postgresql.org/docs/current/datatype-json.html)
- [JSONB and Indexing](https://www.postgresql.org/docs/current/datatype-json.html)
- [GIN Indexes with JSONB](https://www.postgresql.org/docs/current/gin.html)
