import os
import csv
import asyncpg
from dotenv import load_dotenv
from azure.identity import DefaultAzureCredential
from azure.storage.blob.aio import BlobServiceClient
import asyncio
import urllib.parse


GRAPH_NAME = 'vendor_graph'


async def main():
    """Load data into Azure Database for PostgreSQL Graph Database using cypher queries and asyncpg."""
    load_dotenv()
    print("Loading environment variables...")

    server = os.getenv("POSTGRESQL_SERVER_NAME")
    database = 'contracts'
    username = os.getenv("ENTRA_ID_USERNAME")
    account_name = os.getenv("STORAGE_ACCOUNT_NAME")


    # Download CSV data files from Azure Blob Storage
    local_data_dir = 'graph_data/'
    print("Downloading CSV files from Azure Blob Storage...")
    await download_csvs(account_name, local_data_dir)

    connection_uri = get_connection_string(server, database, username)
    conn = await asyncpg.connect(dsn=connection_uri)
    
    # Connect to PostgreSQL using asyncpg
    print("Connecting to the PostgreSQL database with asyncpg...")
    try:
        await create_and_load_graph_data(conn, local_data_dir)
    finally:
        await conn.close()
    print("Graph data loaded successfully!")

def get_connection_string(host: str, database_name: str, username: str, sslmode: str = "require"):
    """Get the connection string for the PostgreSQL database."""
    
    # Get a token for the Azure Database for PostgreSQL server
    credential = DefaultAzureCredential()
    token = credential.get_token("https://ossrdbms-aad.database.windows.net")

    conn_str = f"postgresql://{urllib.parse.quote_plus(username)}:{token.token}@{host}:5432/{database_name}?sslmode={sslmode}"
    return conn_str

async def create_and_load_graph_data(conn, local_data_dir: str):
    """Create a graph in the PostgreSQL database and load data from CSV files."""
    await conn.execute(f'SET search_path = ag_catalog, "$user", public;')

    # Create the graph
    await conn.execute(f'SELECT * FROM ag_catalog.create_graph($1);', GRAPH_NAME)
 
    # Load vendors.csv
    print("Loading vendors.csv...")
    with open(f'{local_data_dir}vendors.csv', newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            await create_vendor_vertex(conn, row)

    # Load sows.csv
    print("Loading sows.csv...")
    with open(f'{local_data_dir}sows.csv', newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            await create_sow_vertex(conn, row)

    # Load has_invoices.csv
    print("Loading has_invoices.csv...")
    with open(f'{local_data_dir}has_invoices.csv', newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            await create_has_invoices_edge(conn, row)

async def create_vendor_vertex(conn, vendor: dict):
    """Execute cypher query to create a product vertex."""
    cypher_query = f"""
        SELECT * FROM cypher('{GRAPH_NAME}', $$
            CREATE (v:vendor {{
            id: "{vendor['id']}",
            name: "{vendor['name']}",
            address: "{vendor['address']}",
            website: "{vendor['website']}", 
            type: "{vendor['type']}",
            contact_name: "{vendor['contact_name']}",
            contact_email: "{vendor['contact_email']}",
            contact_phone: "{vendor['contact_phone']}",
            contact_phone: "{vendor['contact_phone']}"
            }})
            RETURN count(v)
        $$) AS (count agtype);
    """
    await conn.execute(cypher_query)

async def create_sow_vertex(conn, sow: dict):
    """Execute cypher query to create a review vertex."""
    cypher_query = f"""
        SELECT * FROM cypher('{GRAPH_NAME}', $$
            CREATE (s:sow {{
            id: "{sow['id']}",
            number: "{sow['number']}",
            vendor_id: "{sow['vendor_id']}",
            start_date: "{sow['start_date']}", 
            end_date: "{sow['end_date']}",
            budget: "{sow['budget']}"
            }})
            RETURN count(s)
        $$) AS (count agtype);
    """
    await conn.execute(cypher_query)

async def create_has_invoices_edge(conn, edge_data: dict):
    """Create edge between product and feature nodes."""
    start_vertex_type = edge_data['start_vertex_type']
    end_vertex_type = edge_data['end_vertex_type']
    start_id = edge_data['start_id']
    end_id = edge_data['end_id']

    cypher_query = f"""
       SELECT * FROM ag_catalog.cypher('{GRAPH_NAME}', $$
            MATCH (v:{start_vertex_type}), (s:{end_vertex_type})
            WHERE v.id = "{start_id}" AND s.id = "{end_id}"
            CREATE (v)-[rel:has_invoices 
                {{id: "{edge_data['id']}",
                amount: "{edge_data['amount']}",
                number: "{edge_data['number']}",
                invoice_date: "{edge_data['invoice_date']}",
                payment_status: "{edge_data['payment_status']}"
            }}]->(s)
            RETURN count(rel) as rel_count
        $$) as (rel_count agtype);
    """
    await conn.execute(cypher_query)

async def download_csvs(account_name:str, local_data_directory: str):
    """Download CSV files from Azure Blob Storage."""

    # Create connection to the blob storage account
    account_blob_endpoint = f"https://{account_name}.blob.core.windows.net/"
    # Connect to the blob service client using Entra ID authentication
    client = BlobServiceClient(account_url=account_blob_endpoint, credential=DefaultAzureCredential())

    # List the blobs in the graph container with a CSV extension
    async with client:
        async for blob in client.get_container_client('graph').list_blobs():
            if blob.name.endswith('.csv'):
                # Download the CSV file to a local directory
                await download_csv(client, blob.name, local_data_directory)

async def download_csv(client: BlobServiceClient, blob_path: str, local_data_dir: str):
    """Download a CSV file from Azure Blob Storage."""
    # Get the blob
    blob_client = client.get_blob_client(container='graph', blob=blob_path)

    async with blob_client:
        # Download the CSV file
        if await blob_client.exists():
            # create a local directory if it does not exist
            if not os.path.exists(local_data_dir):
                os.makedirs(local_data_dir)

            with open(f"{local_data_dir}{blob_path.split('/')[-1]}", 'wb') as file:
                stream = await blob_client.download_blob()
                result = await stream.readall()
                # Save the CSV file to a local directory
                file.write(result)

if __name__ == "__main__":
    import asyncio
    import sys

    if sys.platform == "win32":
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

    asyncio.run(main())