-- Database Schema: Todo Management Application
-- Target: Supabase PostgreSQL Database

-- 1. Create the todos table
CREATE TABLE IF NOT EXISTS public.todos (
    id TEXT PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    completed BOOLEAN NOT NULL DEFAULT false,
    priority TEXT NOT NULL DEFAULT 'medium',
    category TEXT NOT NULL DEFAULT 'General',
    due_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

-- 3. Define security policies for multi-user security (only own data accessible)
CREATE POLICY "Users can insert their own todos" 
    ON public.todos 
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own todos" 
    ON public.todos 
    FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own todos" 
    ON public.todos 
    FOR UPDATE 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own todos" 
    ON public.todos 
    FOR DELETE 
    USING (auth.uid() = user_id);

-- 4. Enable Realtime subscriptions for todos table
-- Note: Realtime must be enabled on the table to sync across multiple active user sessions.
alter publication supabase_realtime add table public.todos;
