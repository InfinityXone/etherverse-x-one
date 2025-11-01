-- Infinity Swarm Memory Schema
create table if not exists agent_logs (
  id uuid primary key default gen_random_uuid(),
  agent_name text,
  event_type text,
  payload jsonb,
  created_at timestamp default now()
);
