CREATE EXTENSION IF NOT EXISTS azure_ai;
CREATE EXTENSION IF NOT EXISTS pg_diskann CASCADE;
-- TODO: Update steps to use CASCADE on the pg_diskann extension, and explain how this will also install the vector extension.
--CREATE EXTENSION IF NOT EXISTS vector;

-- Use managed identity for Azure 
SELECT azure_ai.set_setting('azure_openai.auth_type', 'managed-identity');
--SELECT azure_ai.set_setting('azure_openai.auth_type', 'subscription-key');
SELECT azure_ai.set_setting('azure_openai.endpoint', 'https://aif-l55fupi5oju6q.openai.azure.com/');

-- Verify settings
SELECT azure_ai.get_setting('azure_openai.auth_type');
SELECT azure_ai.get_setting('azure_openai.endpoint');
-- Test embeddings
SELECT azure_openai.create_embeddings('embeddings', 'The quick brown fox jumps over the lazy dog');


-- Set up cognitive services endpoint
SELECT azure_ai.set_setting('azure_cognitive.auth_type', 'managed-identity');
SELECT azure_ai.set_setting('azure_cognitive.endpoint', 'https://aif-l55fupi5oju6q.cognitiveservices.azure.com/');
-- Test summarization
SELECT azure_cognitive.summarize_extractive('This is a document with a lot of text. The document is very wordy. When the wind blows, the document has more words.', 'en', 2);


-- Set up serverless ranking endpoint
SELECT azure_ai.set_setting('azure_ml.serverless_ranking_endpoint', 'https://cohere-rerank-v3-5-sdkf473iohepa.eastus.models.ai.azure.com/v1/rerank');

-- Execute a ranking query
WITH reviews(id, review) AS (
    VALUES
        (1, 'The product has a great battery life.'),
        (2, 'Noise cancellation does not work as advertised. Avoid this product.'),
        (3, 'The product has a good design, but it is a bit heavy. Not recommended for travel.'),
        (4, 'Music quality is good but call quality could have been better.')
)
SELECT
    rank,
    id,
    review
FROM
    azure_ai.rank(
        'clear calling capability that blocks out background noise',
        ARRAY(SELECT review FROM reviews ORDER BY id ASC),
        ARRAY(SELECT id FROM reviews ORDER BY id ASC)
    ) rr
LEFT JOIN
    reviews r USING (id)
ORDER BY
    rank ASC;