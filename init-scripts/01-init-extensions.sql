-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Criar role para API anônima
CREATE ROLE web_anon NOLOGIN;

-- Configurar permissões básicas
GRANT USAGE ON SCHEMA public TO web_anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO web_anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO web_anon;

-- Exemplo de tabela com vector
CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding vector(1536), -- Dimensão do OpenAI
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índice para busca vetorial
CREATE INDEX IF NOT EXISTS documents_embedding_idx ON documents 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Permitir acesso à tabela
GRANT SELECT, INSERT, UPDATE, DELETE ON documents TO web_anon;
GRANT USAGE, SELECT ON SEQUENCE documents_id_seq TO web_anon;
