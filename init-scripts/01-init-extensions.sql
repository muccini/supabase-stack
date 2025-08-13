-- Extensões necessárias para Supabase + Vector
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA public;

-- Criar schema para o auth
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS realtime;
CREATE SCHEMA IF NOT EXISTS _realtime;

-- Criar usuários necessários
CREATE USER authenticator WITH PASSWORD 'sua_senha_super_secreta';
CREATE USER supabase_auth_admin WITH PASSWORD 'sua_senha_super_secreta';
CREATE USER supabase_storage_admin WITH PASSWORD 'sua_senha_super_secreta';

-- Conceder permissões
GRANT USAGE ON SCHEMA public TO authenticator;
GRANT USAGE ON SCHEMA auth TO authenticator;
GRANT USAGE ON SCHEMA storage TO authenticator;
GRANT USAGE ON SCHEMA realtime TO authenticator;

-- Criar roles necessários
CREATE ROLE anon;
CREATE ROLE authenticated;
CREATE ROLE service_role;

-- Conceder roles
GRANT anon TO authenticator;
GRANT authenticated TO authenticator;
GRANT service_role TO authenticator;

-- Configurar RLS (Row Level Security)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;

-- Exemplo de tabela com vector (remova se não precisar)
CREATE TABLE IF NOT EXISTS embeddings (
    id SERIAL PRIMARY KEY,
    content TEXT,
    metadata JSONB,
    embedding vector(1536), -- Ajuste a dimensão conforme necessário
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índice para busca por similaridade vetorial
CREATE INDEX IF NOT EXISTS embeddings_embedding_idx ON embeddings 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Habilitar RLS na tabela
ALTER TABLE embeddings ENABLE ROW LEVEL SECURITY;

-- Política RLS básica (ajuste conforme necessário)
CREATE POLICY "Allow read access" ON embeddings FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow insert for authenticated users" ON embeddings FOR INSERT TO authenticated WITH CHECK (true);
