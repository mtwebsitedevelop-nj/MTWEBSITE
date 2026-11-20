-- MTECH website: run this ONCE in Supabase > SQL Editor > New query > Run
create table if not exists public.site_data (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz default now()
);
create table if not exists public.leads (
  id bigserial primary key,
  created_at timestamptz default now(),
  data jsonb not null
);

alter table public.site_data enable row level security;
alter table public.leads enable row level security;

-- everyone can READ the products / logos / slides / chat message
drop policy if exists "public read site_data" on public.site_data;
create policy "public read site_data" on public.site_data for select using (true);

-- only the logged-in admin can WRITE them
drop policy if exists "admin insert site_data" on public.site_data;
create policy "admin insert site_data" on public.site_data for insert to authenticated with check (true);
drop policy if exists "admin update site_data" on public.site_data;
create policy "admin update site_data" on public.site_data for update to authenticated using (true) with check (true);
drop policy if exists "admin delete site_data" on public.site_data;
create policy "admin delete site_data" on public.site_data for delete to authenticated using (true);

-- visitors can SEND an enquiry; only the admin can read or clear them
drop policy if exists "anyone can send enquiry" on public.leads;
create policy "anyone can send enquiry" on public.leads for insert to anon, authenticated with check (true);
drop policy if exists "admin read leads" on public.leads;
create policy "admin read leads" on public.leads for select to authenticated using (true);
drop policy if exists "admin delete leads" on public.leads;
create policy "admin delete leads" on public.leads for delete to authenticated using (true);

-- table permissions (needed in addition to the policies above)
grant usage on schema public to anon, authenticated;
grant select on public.site_data to anon, authenticated;
grant insert, update, delete on public.site_data to authenticated;
grant insert on public.leads to anon, authenticated;
grant select, delete on public.leads to authenticated;
grant usage, select on sequence public.leads_id_seq to anon, authenticated;
