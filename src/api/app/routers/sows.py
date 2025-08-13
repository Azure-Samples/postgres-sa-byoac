from app.lifespan_manager import get_db_connection_pool, get_storage_service, get_azure_doc_intelligence_service
from app.models import Sow, SowEdit, SowChunk, ListResponse, SowAnalyzeResult
from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, Form
from datetime import datetime
from pydantic import parse_obj_as
import json
import traceback

# Initialize the router
router = APIRouter(
    prefix = "/sows",
    tags = ["SOWs"],
    dependencies = [Depends(get_db_connection_pool)],
    responses = {404: {"description": "Not found"}}
)


@router.get("/", response_model=ListResponse[Sow])
async def list_sows(vendor_id: int = -1, skip: int = 0, limit: int = 10, sortby: str = None, pool = Depends(get_db_connection_pool)):
    """Retrieves a list of SOWs from the database."""
    orderby = 'id'
    if (sortby):
        orderby = sortby
    async with pool.acquire() as conn:
       
        if (limit < 0):
            if(vendor_id > 0):
                rows = await conn.fetch('SELECT * FROM sows WHERE vendor_id = $1 ORDER BY $2;', vendor_id, orderby)
            else:
                rows = await conn.fetch('SELECT * FROM sows ORDER BY $1;', orderby)
        else:
            if(vendor_id > 0):
                rows = await conn.fetch('SELECT * FROM sows WHERE vendor_id = $1 ORDER BY $2 LIMIT $3 OFFSET $4;', vendor_id, orderby, limit, skip)
            else:
                rows = await conn.fetch('SELECT * FROM sows ORDER BY $1 LIMIT $2 OFFSET $3;', orderby, limit, skip)

        sows = parse_obj_as(list[Sow], [dict(row) for row in rows])

        if (vendor_id > 0):
            total = await conn.fetchval('SELECT COUNT(*) FROM sows WHERE vendor_id = $1;', vendor_id)
        else:
            total = await conn.fetchval('SELECT COUNT(*) FROM sows;')

    if (limit < 0):
        limit = total

    return ListResponse[Sow](data=sows, total = total, skip = skip, limit = limit)


@router.get("/{sow_id}", response_model=Sow)
async def get_by_id(sow_id: int, pool = Depends(get_db_connection_pool)):
    """Retrieves a SOW by ID from the database."""
    async with pool.acquire() as conn:
        row = await conn.fetchrow('SELECT * FROM sows WHERE id = $1;', sow_id)
        if row is None:
            raise HTTPException(status_code=404, detail=f'A SOW with an id of {sow_id} was not found.')
        sow = parse_obj_as(Sow, dict(row))
    return sow


@router.post("/", response_model=SowAnalyzeResult)
async def analyze_sow(
    file: UploadFile = File(...),
    vendor_id: int = Form(...),
    pool = Depends(get_db_connection_pool),
    storage_service = Depends(get_storage_service),
    doc_intelligence_service = Depends(get_azure_doc_intelligence_service)
):
    """Analyze a SOW document and create a new SOW in the database."""
    try:

        # Get vendor_id from vendor_id
        async with pool.acquire() as conn:
            vendor_id = await conn.fetchval('SELECT id FROM vendors WHERE id = $1;', vendor_id)
            if vendor_id is None:
                raise HTTPException(status_code=404, detail=f'A vendor with an id of {vendor_id} was not found.')

        # Upload file to Azure Blob Storage
        documentName = await storage_service.save_sow_document(vendor_id, file)

        # Set field defaults
        sow_number = f"SOW-{datetime.now().strftime('%Y-%m%d')}"
        start_date = datetime.strptime("2024-01-01", '%Y-%m-%d').date()
        end_date = datetime.strptime("2024-12-31", '%Y-%m-%d').date()
        budget = 0
        metadata = {}

        # Analyze the document
        document_data = await storage_service.download_blob(documentName)

        analysis_result = await doc_intelligence_service.extract_text_from_sow_document(document_data)
        full_text = analysis_result.full_text

        metadata = doc_intelligence_service.extract_sow_metadata(full_text)

        # Get SOW ID from metadata
        sow_number = metadata['sow_number'] or None
        sow_id = None # metadata['sow_id']
        if sow_number is not None:
            async with pool.acquire() as conn:
                sow_id = await conn.fetchval('SELECT id FROM sows WHERE vendor_id = $1 AND number = $2;', vendor_id, sow_number)
               

        # Create SOW in the database
        async with pool.acquire() as conn:
            if sow_id is None:
                # Create new SOW
                row = await conn.fetchrow('''
                    INSERT INTO sows (number, start_date, end_date, budget, document, metadata, summary, vendor_id)
                    VALUES (
                    $1, $2, $3, $4, $5, $6, 
                    azure_cognitive.summarize_abstractive($7, 'en', 2), --azure_cognitive.summarize_abstractive($7, 'en', 2),
                    $8)
                    RETURNING *;
                ''', sow_number, start_date, end_date, budget, documentName, json.dumps(metadata), full_text, vendor_id)
            else:
                # Update existing SOW with new document
                row = await conn.fetchrow('''
                    UPDATE sows
                    SET start_date = $1,
                        end_date = $2,
                        budget = $3,
                        document = $4,
                        metadata = $5,
                        summary = azure_cognitive.summarize_abstractive($6, 'en', 2) --azure_cognitive.summarize_abstractive($6, 'en', 2)
                    WHERE id = $7
                    RETURNING *;
                ''', start_date, end_date, budget, documentName, json.dumps(metadata), full_text, sow_id)

            if row is None:
                raise HTTPException(status_code=500, detail=f'An error occurred while creating the SOW.')

            sow = parse_obj_as(Sow, dict(row))


            # Save the text chunks for the SOW
            await conn.execute('''DELETE FROM sow_chunks WHERE sow_id = $1''', sow.id)
            for chunk in analysis_result.text_chunks:
                await conn.execute('''
                    INSERT INTO sow_chunks (sow_id, heading, content, page_number) VALUES ($1, $2, $3, $4);
                ''', sow.id, chunk.heading, chunk.content, chunk.page_number)

        return SowAnalyzeResult(hasError=False, error=None, message="SOW analyzed successfully.", sow=sow)

    except Exception as e:
        print(e) # output error to console
        # return stack trace
        return SowAnalyzeResult(hasError=True, error=traceback.format_exc(), message=str(e), sow=None)


@router.put("/{sow_id}", response_model=Sow)
async def update_sow(sow_id: int, sow_update: SowEdit, pool = Depends(get_db_connection_pool)):
    """Updates a SOW in the database."""
    async with pool.acquire() as conn:
        sow = await get_by_id(sow_id, pool)
        if sow is None:
            raise HTTPException(status_code=404, detail=f'A SOW with an id of {sow_id} was not found.')

        sow.number = sow_update.number
        sow.start_date = sow_update.start_date
        sow.end_date = sow_update.end_date
        sow.budget = sow_update.budget
        sow.vendor_id = sow_update.vendor_id

        # for key, value in sow_update.dict().items():
        #     setattr(sow, key, value)
        row = await conn.fetchrow('''
            UPDATE sows
            SET number = $1, start_date = $2, end_date = $3, budget = $4, vendor_id = $5
            WHERE id = $6
            RETURNING *;''',
            sow.number, sow.start_date, sow.end_date, sow.budget, sow.vendor_id, sow_id)
        if row is None:
            raise HTTPException(status_code=404, detail=f'A SOW with an id of {sow_id} was not found.')
        updated_sow = parse_obj_as(Sow, dict(row))
    return updated_sow

@router.delete("/{id}", response_model=Sow)
async def delete_sow(id: int, pool = Depends(get_db_connection_pool), storage_service = Depends(get_storage_service)):
    """Deletes a SOW from the database."""   
    async with pool.acquire() as conn:
        row = await conn.fetchrow('SELECT * FROM sows WHERE id = $1;', id)
        if row is None:
            raise HTTPException(status_code=404, detail=f'A sow with an id of {id} was not found.')
        sow = parse_obj_as(Sow, dict(row))

        # Delete the document from Azure Blob Storage
        await storage_service.delete_document(sow.document)

        # Delete the SOW
        await conn.execute('DELETE FROM sows WHERE id = $1;', id)
    return sow


@router.get("/{sow_id}/chunks", response_model=ListResponse[SowChunk])
async def get_sow_chunks(sow_id: int, pool = Depends(get_db_connection_pool)):
    """Retrieves a list of SOW chunks from the database."""
    async with pool.acquire() as conn:
        rows = await conn.fetch('SELECT * FROM sow_chunks WHERE sow_id = $1 ORDER BY page_number, heading;', sow_id)
        sow_chunks = parse_obj_as(list[SowChunk], [dict(row) for row in rows])
    return ListResponse[SowChunk](data=sow_chunks, total=len(sow_chunks), skip=0, limit=len(sow_chunks))