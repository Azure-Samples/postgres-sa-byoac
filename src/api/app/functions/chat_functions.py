class ChatFunctions:
    def __init__(self, db_pool, embedding_client):
        self.pool = db_pool
        self.embedding_client = embedding_client

    async def __create_query_embeddings(self, user_query: str):
        """
        Generates vector embeddings for the user query.
        """
        # Create embeddings using the LangChain Azure OpenAI Embeddings client
        # This makes an API call to the Azure OpenAI service to generate embeddings,
        # which can be used to compare the user query with vectorized data in the database.
        query_embeddings = await self.embedding_client.aembed_query(user_query)
        return query_embeddings
    
    async def __execute_query(self, query: str, *params):
        """
        Executes a query on the database and returns the results.
        """
        # Acquire a connection from the pool and execute the query
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, *params)
        return [dict(row) for row in rows]
    
    async def __execute_graph_query(self, query: str, *params):
        """
        Executes a query on the database and returns the results.
        """
        # Acquire a connection from the pool and execute the query
        async with self.pool.acquire() as conn:
            # Execute a query to set the search path on the connection
            await conn.execute('SET search_path = ag_catalog, "$user", public;')
            # Execute the graph query
            rows = await conn.fetch(query, *params)
        return [dict(row) for row in rows]
        
    async def __execute_scalar_query(self, query: str, *params):
        """
        Executes a scalar query on the database and returns the result.
        """
        # Acquire a connection from the pool and execute the query
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, *params)
        return row
    
    async def get_invoice_id(self, number: str) -> int:
        """
        Retrieves the ID of a specific invoice by its number.
        """
        query = "SELECT id FROM invoices WHERE number = $1;"
        row = await self.__execute_scalar_query(query, number)
        return row['id'] or None

    async def get_invoice_line_items(self, invoice_id: int):
        """
        Retrieves the line items for a specific invoice by its ID.
        """
        # Define the columns to retrieve from the table
        # Exclude the embedding column in results
        columns = ["id", "invoice_id", "description", "amount", "status"]
        query = f'SELECT {", ".join(columns)} FROM invoice_line_items WHERE invoice_id = $1;'
        
        rows = await self.__execute_query(query, invoice_id)
        return [dict(row) for row in rows]

    async def get_invoice_validation_results(self, invoice_id: int = None):
        """
        Retrieves invoice accuracy and performance validation results for the specified invoice.
        If no invoice_id is provided, return all invoice validation results.
        """
        # Define the columns to retrieve from the table
        # This excludes the embedding column in results
        columns = ["invoice_id", "datestamp", "result", "validation_passed"]
        query = f'SELECT {", ".join(columns)} FROM invoice_validation_results'
        params = []
        # Filter the validation results by invoice_id
        if invoice_id is not None:
            query += ' WHERE invoice_id = $1'
            params.append(invoice_id)

        rows = await self.__execute_query(f'{query};', *params)
        return [dict(row) for row in rows]

    async def get_invoices(self, invoice_id: int = None, vendor_id: int = None, sow_id: int = None):
        """
        Retrieves a list of invoices from the database for a specified vendor or sow.
        If no vendor_id, invoice_id, or sow_id is provided, return all invoices.
        """
        # Define the columns to retrieve from the table
        # This excludes a few columns that are large and not needed for the chat function
        columns = ["id", "number", "vendor_id", "sow_id", "amount", "invoice_date", "payment_status"]
        query = f'SELECT {", ".join(columns)} FROM invoices'
        
        params = []
        where_clauses = []
        param_count = 1

        # Filter the invoices by invoice_id, vendor_id or sow_id, if provided
        if invoice_id is not None:
            where_clauses.append(f'id = ${param_count}')
            params.append(invoice_id)
            param_count += 1
        else:
            if vendor_id is not None:
                where_clauses.append(f'vendor_id = ${param_count}')
                params.append(vendor_id)
                param_count += 1
            if sow_id is not None:
                where_clauses.append(f'sow_id = ${param_count}')
                params.append(sow_id)
                param_count += 1
        
        if where_clauses:
            query += ' WHERE ' + ' AND '.join(where_clauses)

        rows = await self.__execute_query(f'{query};', *params)
        return [dict(row) for row in rows]
    
    async def get_unpaid_invoices_for_vendor(self, vendor_id: int):
        """
        Retrieves a list of unpaid invoices for a specific vendor using a graph query.
        """
        # Define the graph query
        graph_query = f"""SELECT * FROM ag_catalog.cypher('vendor_graph', $$
        MATCH (v:vendor {{id: $1}})-[rel:has_invoices]->(s:sow)
        WHERE rel.payment_status <> 'Paid'
        RETURN v.id AS vendor_id, v.name AS vendor_name, s.id AS sow_id, s.number AS sow_number, rel.id AS invoice_id, rel.number AS invoice_number, rel.payment_status AS payment_status
        $$, $2) as (vendor_id BIGINT, vendor_name TEXT, sow_id BIGINT, sow_number TEXT, invoice_id BIGINT, invoice_number TEXT, payment_status TEXT);
        """
        rows = await self.__execute_graph_query(graph_query, str(vendor_id), f'[{{"id": "{vendor_id}"}}]')
        return [dict(row) for row in rows]

    async def get_sow_id(self, number: str) -> int:
        """
        Retrieves the ID of a specific SOW by its number.
        """
        query = "SELECT id FROM sows WHERE number = $1;"
        row = await self.__execute_scalar_query(query, number)
        return row.get('id', None)

    async def get_sow_chunks(self, sow_id: int):
        """
        Retrieves the content chunks for a specific statement of work (SOW) by its ID.
        Chunks include section headings and the text content under that header, along with page number
        the chunk can be found on in the document.
        """
        # Define the columns to retrieve from the table
        # This excludes the embedding column in results
        columns = ["id", "sow_id", "heading", "content", "page_number"]
        query = f'SELECT {", ".join(columns)} FROM sow_chunks WHERE sow_id = $1;'

        rows = await self.__execute_query(query, sow_id)
        return [dict(row) for row in rows]

    async def get_sow_milestones(self, sow_id: int):
        """
        Retrieves a list of milestones for a specific statement of work (SOW) by its ID.
        """
        query = 'SELECT * FROM milestones WHERE sow_id = $1;'
        rows = await self.__execute_query(query, sow_id)
        return [dict(row) for row in rows]
    
    async def get_milestone_deliverables(self, milestone_id: int):
        """
        Retrieves the deliverables for a specific milestone by its ID.
        """
        # Define the columns to retrieve from the table
        # This excludes the embedding column in results
        columns = ["id", "milestone_id", "description", "amount", "status", "due_date"]
        query = f'SELECT {", ".join(columns)} FROM deliverables WHERE milestone_id = $1'

        rows = await self.__execute_query(query, milestone_id)
        return [dict(row) for row in rows]

    async def get_sow_validation_results(self, sow_id: int = None):
        """
        Retrieves SOW accuracy and performance validation results for the specified SOW or vendor.
        If no sow_id is provided, return all SOW validation results
        """
        # Define the columns to retrieve from the table
        # This excludes the embedding column in results
        columns = ["sow_id", "datestamp", "result", "validation_passed"]
        query = f'SELECT {", ".join(columns)} FROM sow_validation_results'
        params = []
        # Filter the validation results by sow_id
        if sow_id is not None:
            query += ' WHERE sow_id = $1'
            params.append(sow_id)

        rows = await self.__execute_query(f'{query};', *params)
        return [dict(row) for row in rows]

    async def get_sows(self, sow_id: int = None, vendor_id: int = None):
        """
        Retrieves a list of statements of work (SOWs) from the database for the specified vendor.
        If no vendor_id or sow_id is provided, return all SOWs.
        """
        # Define the columns to retrieve from the table
        # This excludes a few columns that are large and not needed for the chat function
        columns = ["id", "number", "vendor_id", "start_date", "end_date", "budget", "summary"]

        # Build a SELECT query and JOIN from the tables and columns
        query = f'SELECT {", ".join(columns)} FROM sows'
        
        params = []
        where_clauses = []
        param_count = 1

        # Filter the SOWs by vendor_id, if provided
        if sow_id is not None:
            where_clauses.append(f'id = ${param_count}')
            params.append(sow_id)
            param_count += 1
        elif vendor_id is not None:
            where_clauses.append(f'vendor_id = ${param_count}')
            params.append(vendor_id)
            param_count += 1

        if where_clauses:
            query += ' WHERE ' + ' AND '.join(where_clauses)

        rows = await self.__execute_query(f'{query};', *params)
        return [dict(row) for row in rows]

    async def get_vendors(self):
        """Retrieves a list of vendors from the database."""
        rows = await self.__execute_query('SELECT * FROM vendors;')
        return [dict(row) for row in rows]

    """
    The following methods are used for hybrid searches against the database.
    """

    async def find_milestone_deliverables(self, user_query: str, sow_id: int = None):
        """
        Retrieves milestone deliverables similar to the user query for the specified SOW.
        If no sow_id is provided, return all similar deliverables.
        """
        # Define the columns to retrieve from the table
        # Exclude the embedding column in results
        columns = ["id", "milestone_id", "description", "status"]

        # Get the embeddings for the user query
        query_embeddings = await self.__create_query_embeddings(user_query)

        # Use hybrid search to rank records, with exact matches ranked highest
        columns.append(f"""CASE
                            WHEN description ILIKE $1 THEN 0
                            ELSE (embedding <=> $2)::real
                        END as rank""")

        query = f'SELECT {", ".join(columns)} FROM deliverables'
        params = [f'%{user_query}%', query_embeddings]
        # Filter the deliverables by sow_id, if provided
        if sow_id is not None:
            query += ' WHERE sow_id = $3'
            params.append(sow_id)

        query += ' ORDER BY rank ASC'

        rows = await self.__execute_query(f'{query};', *params)
        return [dict(row) for row in rows]
    
    async def find_invoice_line_items(self, user_query: str, invoice_id: int = None):
        """
        Retrieves invoice line items similar to the user query for the specified invoice.
        If no invoice_id is provided, return all similar line items.
        """
        # Define the columns to retrieve from the table
        # Exclude the embedding column in results
        columns = ["id", "invoice_id", "description", "amount", "status"]

        # Get the embeddings for the user query
        query_embeddings = await self.__create_query_embeddings(user_query)

        # Use hybrid search to rank records, with exact matches ranked highest
        columns.append(f"""CASE
                            WHEN description ILIKE $1 THEN 0
                            ELSE (embedding <=> $2)::real
                        END as rank""")

        query = f'SELECT {", ".join(columns)} FROM invoice_line_items'
        params = [f'%{user_query}%', query_embeddings]
        # Filter the line items by invoice_id, if provided
        if invoice_id is not None:
            query += ' WHERE invoice_id = $3'
            params.append(invoice_id)

        query += ' ORDER BY rank ASC'

        rows = await self.__execute_query(f'{query};', *params)
        return [dict(row) for row in rows]

    async def find_invoice_validation_results(self, user_query: str, invoice_id: int = None):
        """
        Retrieves invoice accuracy and performance validation results similar to the user query for specified invoice.
        If invoice_id is not provided, return all similar validation results.
        """
        # Define the columns to retrieve from the table
        # Exclude the embedding column in results
        columns = ["invoice_id", "datestamp", "result", "validation_passed"]

        # Get the embeddings for the user query
        query_embeddings = await self.__create_query_embeddings(user_query)

        # Use hybrid search to rank records, with exact matches ranked highest
        columns.append(f"""CASE
                            WHEN result ILIKE $1 THEN 0
                            ELSE (embedding <=> $2)::real
                        END as rank""")
        
        query = f'SELECT {", ".join(columns)} FROM invoice_validation_results'

        params = [f'%{user_query}%', query_embeddings]
        # Filter by invoice_id, if provided
        if invoice_id is not None:
            query += ' WHERE invoice_id = $3'
            params.append(invoice_id)
        
        # Order the results by rank
        query += ' ORDER BY rank ASC'

        rows = await self.__execute_query(f'{query};', *params)
        return [dict(row) for row in rows]

    async def find_sow_chunks(self, user_query: str, sow_id: int = None):
        """
        Retrieves content chunks similar to the user query for the specified SOW.
        """
        # Define the columns to retrieve from the table
        # Exclude the embedding column in results
        columns = ["id", "sow_id", "heading", "content", "page_number"]

        # Get the embeddings for the user query
        query_embeddings = await self.__create_query_embeddings(user_query)

        # Use hybrid search to rank records, with exact matches ranked highest
        columns.append(f"""CASE
                            WHEN content ILIKE $1 THEN 0
                            ELSE (embedding <=> $2)::real
                        END as rank""")

        query = f'SELECT {", ".join(columns)} FROM sow_chunks'
        params = [f'%{user_query}%', query_embeddings]
        if sow_id is not None:
            query += ' WHERE sow_id = $3'
            params.append(sow_id)

        query += ' ORDER BY rank ASC'

        rows = await self.__execute_query(f'{query};', *params)
        return [dict(row) for row in rows]
    
    async def find_sow_chunks_with_semantic_ranking(self, user_query: str, sow_id: int = None, max_results: int = 3):
        """
        Retrieves content chunks similar to the user query for the specified SOW.
        """

        # Get the embeddings for the user query
        query_embeddings = await self.__create_query_embeddings(user_query)

        # Create a vector search query
        cte_query = "SELECT content FROM sow_chunks"
        params = [query_embeddings]
        if sow_id is not None:
            cte_query += " WHERE sow_id = $2"
            params.append(sow_id)
        
        cte_query += " ORDER BY embedding <=> $1"
        cte_query += " LIMIT 10"

        # Create the semantic ranker query
        query = f"""
        WITH vector_results AS (
            {cte_query}
        )
        SELECT content, relevance
        FROM semantic_reranking($1,  ARRAY(SELECT content from vector_results))
        ORDER BY relevance DESC
        LIMIT {max_results};
        """

        rows = await self.__execute_query(query, user_query, *params)
        return [dict(row) for row in rows]
    
    async def find_sow_validation_results(self, user_query: str, sow_id: int = None): 
        """
        Retrieves SOW accuracy and performance validation results similar to the user query for specified SOW.
        If no sow_id is provided, return all similar validation results.
        """
        # Define the columns to retrieve from the table
        # Exclude the embedding column in results
        columns = ["sow_id", "datestamp", "result", "validation_passed"]

        #Get the embeddings for the user query
        query_embeddings = await self.__create_query_embeddings(user_query)

        # Get the embeddings for the user query
        columns.append(f"""CASE
                            WHEN result ILIKE $1 THEN 0
                            ELSE (embedding <=> $2)::real
                        END as rank""")

        # Use hybrid search to rank records, with exact matches ranked highest
        columns.append(f"(embedding <=> $2)::real as rank")

        query = f'SELECT {", ".join(columns)} FROM sow_validation_results'
        params = [f'%{user_query}%', query_embeddings]
        if sow_id is not None:
            query += ' WHERE sow_id = $3'
            params.append(sow_id)

        query += ' ORDER BY rank ASC'

        rows = await self.__execute_query(f'{query};', *params)
        return [dict(row) for row in rows]