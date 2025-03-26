# Setup

A starter solution has been provided, which you will be modifying to add rich AI capabilities throughout this workshop. This initial application includes a user-friendly REACT UI, offering an intuitive frontend interface for users to interact with. Additionally, it features a Python-based backend API that handles the core business logic and data processing tasks. Throughout the workshop, you will enhance this existing solution by integrating advanced AI functionalities. This includes adding AI validation for data ingestion and leveraging AI-powered tools to analyze financial documents. You will also a the ability to ask questions over private data through an intelligent copilot. By the end of the workshop, you will have transformed the starter application into a sophisticated, AI-enhanced solution capable of providing deep insights into financial data, improving accuracy, efficiency, and overall performance in the financial services industry.

??? warning "Ensure you completed the prerequisites before starting!"

    Before starting, you should review the [prerequisites](./00-Prerequisites.md) for completing the lab.

To get started building the custom AI-enable Financial Services Industry (FSI) application, you need to:

- **PROVISION** the required Azure infrastructure for the resources needed for the application architecture
- **VALIDATE** that the Azure deployment completed successfully.
- **SETUP** your development environment and configure it to work with the infrastructure.

??? question "Using your own data?"

    This solution accelerator is designed to work with sample vendor, SOW, and invoice data, but you can also use your own PostgreSQL database. If you choose to do so, some modifications will be necessary to ensure compatibility with the existing architecture.

    Key Updates Required:

    1. **Database Connection Configuration**:
    Update the connection settings to point to your existing PostgreSQL instance.
    Ensure appropriate authentication mechanisms are in place, such as managed identity or database credentials.
    2. **Managed Identity Setup (if applicable)**:
    If a managed identity is not already configured, you will need to create one.
    Assign the Storage Blob Data Contributor role to the managed identity on the Azure Storage Account to allow secure access to required data.
    3. **Schema Adjustments**:
    Modify the database schema if your data structure differs from the provided sample data.
    Ensure necessary indexing and performance optimizations are applied to support AI-driven queries.
    4. **Data Ingestion and Processing Updates**:
    Adjust data pipelines and preprocessing steps to work with your data format.
    Review and modify any AI validation logic that references sample datasets.
    5. **Storage & Permissions**:
    Ensure that your AI processing and database services have the correct access (data contributor) permissions to read and process your data.
