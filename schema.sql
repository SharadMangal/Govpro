-- DDL Schema for GovPro Road Construction Monitoring Console
-- Targets: Supabase PostgreSQL (PostgREST API)

-- 1. Authorities Table
CREATE TABLE IF NOT EXISTS authorities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Contractors Table
CREATE TABLE IF NOT EXISTS contractors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Projects Table
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    district VARCHAR(100) NOT NULL,
    authority_id UUID REFERENCES authorities(id) ON DELETE SET NULL,
    contractor_id UUID REFERENCES contractors(id) ON DELETE SET NULL,
    status VARCHAR(50) CHECK (status IN ('in_progress', 'delayed', 'completed')) NOT NULL,
    completion_percent NUMERIC(5, 2) DEFAULT 0.0 CHECK (completion_percent >= 0.0 AND completion_percent <= 100.0) NOT NULL,
    budget NUMERIC(15, 2) NOT NULL,
    length_km NUMERIC(6, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    delay_days INTEGER DEFAULT 0 NOT NULL,
    site_photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Construction Stages Table
CREATE TABLE IF NOT EXISTS stages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    stage_name VARCHAR(255) NOT NULL,
    sequence_order INTEGER NOT NULL,
    completion_percent NUMERIC(5, 2) DEFAULT 0.0 NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Materials Utilized Table
CREATE TABLE IF NOT EXISTS materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    material_name VARCHAR(100) NOT NULL,
    quantity NUMERIC(12, 2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. Monthly Progress Table (for Charts)
CREATE TABLE IF NOT EXISTS monthly_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    month DATE NOT NULL,
    completion_percent NUMERIC(5, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. Notifications & Logs Table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- --- INDEXES FOR PERFORMANCE ---
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_district ON projects(district);
CREATE INDEX IF NOT EXISTS idx_stages_project ON stages(project_id);
CREATE INDEX IF NOT EXISTS idx_materials_project ON materials(project_id);
CREATE INDEX IF NOT EXISTS idx_monthly_progress_project ON monthly_progress(project_id);

-- --- ENABLE PUBLIC READ/WRITE FOR ASSESSMENT PURPOSE ---
ALTER TABLE authorities DISABLE ROW LEVEL SECURITY;
ALTER TABLE contractors DISABLE ROW LEVEL SECURITY;
ALTER TABLE projects DISABLE ROW LEVEL SECURITY;
ALTER TABLE stages DISABLE ROW LEVEL SECURITY;
ALTER TABLE materials DISABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_progress DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- --- SEED DATA INSERTS ---

-- 1. Seed Authorities
INSERT INTO authorities (id, name, logo_url) VALUES 
('a1111111-1111-1111-1111-111111111111', 'NHAI', 'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=120&auto=format&fit=crop&q=60'),
('a2222222-2222-2222-2222-222222222222', 'State PWD', 'https://images.unsplash.com/photo-1541872703-74c5e44368f9?w=120&auto=format&fit=crop&q=60'),
('a3333333-3333-3333-3333-333333333333', 'PMGSY', 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=120&auto=format&fit=crop&q=60')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, logo_url = EXCLUDED.logo_url;

-- 2. Seed Contractors
INSERT INTO contractors (id, name, logo_url) VALUES 
('c1111111-1111-1111-1111-111111111111', 'Green Path Constructions', 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=120&auto=format&fit=crop&q=60'),
('c2222222-2222-2222-2222-222222222222', 'Prime Structurals', 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=120&auto=format&fit=crop&q=60'),
('c3333333-3333-3333-3333-333333333333', 'Bharat Infra Ltd.', 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=120&auto=format&fit=crop&q=60'),
('c4444444-4444-4444-4444-444444444444', 'Eastern Roads Co.', 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=120&auto=format&fit=crop&q=60'),
('c5555555-5555-5555-5555-555555555555', 'Rural Build Pvt.', 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=120&auto=format&fit=crop&q=60')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, logo_url = EXCLUDED.logo_url;

-- 3. Seed Projects (Jharkhand Districts & Stats)
INSERT INTO projects (id, name, district, authority_id, contractor_id, status, completion_percent, budget, length_km, start_date, end_date, delay_days, site_photo_url) VALUES 
('p0101010-1010-1010-1010-101010101010', 'NH-114A Ranchi Bypass Widening', 'Ranchi', 'a1111111-1111-1111-1111-111111111111', 'c3333333-3333-3333-3333-333333333333', 'in_progress', 62.0, 3200000000.0, 42.5, '2024-06-15', '2026-01-20', 0, 'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?w=600&auto=format&fit=crop&q=80'),
('p0202020-2020-2020-2020-202020202020', 'SH-22 Dhanbad – Bokaro Corridor', 'Dhanbad', 'a2222222-2222-2222-2222-222222222222', 'c4444444-4444-4444-4444-444444444444', 'delayed', 35.0, 1800000000.0, 28.0, '2025-01-10', '2026-02-15', 12, 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=600&auto=format&fit=crop&q=80'),
('p0303030-3030-3030-3030-303030303030', 'MDR-08 Jamshedpur Rural Link', 'East Singhbhum', 'a3333333-3333-3333-3333-333333333333', 'c1111111-1111-1111-1111-111111111111', 'completed', 100.0, 450000000.0, 15.0, '2024-06-01', '2025-09-30', 0, 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600&auto=format&fit=crop&q=80'),
('p0404040-4040-4040-4040-404040404040', 'SH-09 Palamu Widening Phase-II', 'Palamu', 'a2222222-2222-2222-2222-222222222222', 'c3333333-3333-3333-3333-333333333333', 'in_progress', 48.0, 1200000000.0, 32.0, '2025-02-15', '2026-03-31', 0, 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&auto=format&fit=crop&q=80'),
('p0505050-5050-5050-5050-505050505050', 'MDR-14 Giridih Village Road', 'Giridih', 'a3333333-3333-3333-3333-333333333333', 'c5555555-5555-5555-5555-555555555555', 'delayed', 22.0, 250000000.0, 18.0, '2025-04-10', '2026-05-20', 18, 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=600&auto=format&fit=crop&q=80'),
('p0606060-6060-6060-6060-606060606060', 'NH-33 Hazaribagh Flyover', 'Hazaribagh', 'a1111111-1111-1111-1111-111111111111', 'c2222222-2222-2222-2222-222222222222', 'in_progress', 78.0, 1500000000.0, 8.5, '2024-11-01', '2026-01-30', 0, 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=600&auto=format&fit=crop&q=80')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, status = EXCLUDED.status, completion_percent = EXCLUDED.completion_percent, budget = EXCLUDED.budget;
