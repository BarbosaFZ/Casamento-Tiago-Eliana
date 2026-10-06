-- Base de dados partilhada do gestor de casamento.
-- Executar no SQL Editor do projeto Supabase.
create table if not exists public.wedding_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.wedding_data (
  id integer primary key check (id = 1),
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.wedding_members enable row level security;
alter table public.wedding_data enable row level security;

revoke all on public.wedding_members from anon, authenticated;
revoke all on public.wedding_data from anon, authenticated;
grant select on public.wedding_members to authenticated;
grant select, insert, update on public.wedding_data to authenticated;

drop policy if exists "members can read their own membership" on public.wedding_members;
create policy "members can read their own membership"
  on public.wedding_members for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "wedding members can read shared data" on public.wedding_data;
create policy "wedding members can read shared data"
  on public.wedding_data for select to authenticated
  using (exists (select 1 from public.wedding_members m where m.user_id = (select auth.uid())));

drop policy if exists "wedding members can create shared data" on public.wedding_data;
create policy "wedding members can create shared data"
  on public.wedding_data for insert to authenticated
  with check (id = 1 and exists (select 1 from public.wedding_members m where m.user_id = (select auth.uid())));

drop policy if exists "wedding members can update shared data" on public.wedding_data;
create policy "wedding members can update shared data"
  on public.wedding_data for update to authenticated
  using (exists (select 1 from public.wedding_members m where m.user_id = (select auth.uid())))
  with check (id = 1 and exists (select 1 from public.wedding_members m where m.user_id = (select auth.uid())));

-- Ativa eventos em tempo real para que a outra pessoa veja atualizações sem recarregar.
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'wedding_data') then
    alter publication supabase_realtime add table public.wedding_data;
  end if;
end
$$;
