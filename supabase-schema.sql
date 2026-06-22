-- SENI RATTAN Finance App - Supabase schema
create extension if not exists pgcrypto;

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  product_type text not null,
  phone text not null,
  bank_name text,
  account_number text,
  account_holder text,
  status text not null default 'Aktif' check (status in ('Aktif','Nonaktif')),
  note text,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.owner_cash (
  id uuid primary key default gen_random_uuid(),
  transaction_date date not null,
  amount numeric(14,2) not null check (amount >= 0),
  receiver text not null,
  note text,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.daily_expenses (
  id uuid primary key default gen_random_uuid(),
  transaction_date date not null,
  category text not null,
  amount numeric(14,2) not null check (amount >= 0),
  note text not null,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.purchases (
  id uuid primary key default gen_random_uuid(),
  transaction_date date not null,
  supplier_id uuid not null references public.suppliers(id),
  amount numeric(14,2) not null check (amount >= 0),
  payment_type text not null check (payment_type in ('cash','tempo')),
  payment_method text not null check (payment_method in ('cash','transfer')),
  note text,
  receipt_path text,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.weekly_expenses (
  id uuid primary key default gen_random_uuid(),
  transaction_date date not null,
  category text not null,
  amount numeric(14,2) not null check (amount >= 0),
  note text not null,
  initial_status text not null default 'unpaid' check (initial_status in ('unpaid','paid')),
  payment_method text not null check (payment_method in ('cash','transfer')),
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  ref_type text not null check (ref_type in ('purchase','weekly')),
  ref_id uuid not null,
  amount numeric(14,2) not null check (amount > 0),
  method text not null check (method in ('cash','transfer')),
  payment_date date not null,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.daily_closings (
  id uuid primary key default gen_random_uuid(),
  closing_date date not null unique,
  physical_cash numeric(14,2) not null check (physical_cash >= 0),
  expected_cash numeric(14,2) not null,
  difference numeric(14,2) not null,
  returned_to text not null,
  note text,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create index if not exists owner_cash_date_idx on public.owner_cash(transaction_date);
create index if not exists daily_expenses_date_idx on public.daily_expenses(transaction_date);
create index if not exists purchases_date_idx on public.purchases(transaction_date);
create index if not exists purchases_supplier_idx on public.purchases(supplier_id);
create index if not exists weekly_expenses_date_idx on public.weekly_expenses(transaction_date);
create index if not exists payments_ref_idx on public.payments(ref_type, ref_id);
create index if not exists payments_date_idx on public.payments(payment_date);
create index if not exists daily_closings_date_idx on public.daily_closings(closing_date);

alter table public.suppliers enable row level security;
alter table public.owner_cash enable row level security;
alter table public.daily_expenses enable row level security;
alter table public.purchases enable row level security;
alter table public.weekly_expenses enable row level security;
alter table public.payments enable row level security;
alter table public.daily_closings enable row level security;

-- All signed-in staff share the same company data.
do $$
declare t text;
begin
  foreach t in array array['suppliers','owner_cash','daily_expenses','purchases','weekly_expenses','payments','daily_closings'] loop
    execute format('drop policy if exists "Authenticated users full access" on public.%I', t);
    execute format('create policy "Authenticated users full access" on public.%I for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;

grant usage on schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;

-- USER ROLES: Aan = sekretaris, Febri = owner
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null check (role in ('secretary','owner')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create or replace function public.is_owner()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'owner'
  );
$$;

grant execute on function public.is_owner() to authenticated;
grant select on public.profiles to authenticated;

drop policy if exists "Users read profiles" on public.profiles;
create policy "Users read profiles" on public.profiles
for select to authenticated using (id = auth.uid() or public.is_owner());

drop policy if exists "Owner manages profiles" on public.profiles;
create policy "Owner manages profiles" on public.profiles
for all to authenticated using (public.is_owner()) with check (public.is_owner());

-- Replace broad access: both users may read/input/update; only owner may delete.
do $$
declare t text;
begin
  foreach t in array array['suppliers','owner_cash','daily_expenses','purchases','weekly_expenses','payments','daily_closings'] loop
    execute format('drop policy if exists "Authenticated users full access" on public.%I', t);
    execute format('drop policy if exists "Staff read" on public.%I', t);
    execute format('drop policy if exists "Staff insert" on public.%I', t);
    execute format('drop policy if exists "Staff update" on public.%I', t);
    execute format('drop policy if exists "Owner delete" on public.%I', t);
    execute format('create policy "Staff read" on public.%I for select to authenticated using (true)', t);
    execute format('create policy "Staff insert" on public.%I for insert to authenticated with check (true)', t);
    execute format('create policy "Staff update" on public.%I for update to authenticated using (true) with check (true)', t);
    execute format('create policy "Owner delete" on public.%I for delete to authenticated using (public.is_owner())', t);
  end loop;
end $$;

-- SETUP SETELAH MEMBUAT 2 USER DI AUTHENTICATION.
-- Ganti email contoh di bawah dengan email login Aan dan Febri, lalu jalankan terpisah.
-- insert into public.profiles (id, full_name, role)
-- select id, 'Aan', 'secretary' from auth.users where email = 'EMAIL_AAN'
-- on conflict (id) do update set full_name = excluded.full_name, role = excluded.role;
-- insert into public.profiles (id, full_name, role)
-- select id, 'Febri', 'owner' from auth.users where email = 'EMAIL_FEBRI'
-- on conflict (id) do update set full_name = excluded.full_name, role = excluded.role;


-- Private bucket for supplier purchase receipts
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('purchase-receipts','purchase-receipts',false,5242880,array['image/jpeg','image/png','image/webp','application/pdf'])
on conflict (id) do update set public=false, file_size_limit=5242880, allowed_mime_types=excluded.allowed_mime_types;

drop policy if exists "Authenticated users read purchase receipts" on storage.objects;
create policy "Authenticated users read purchase receipts" on storage.objects for select to authenticated using (bucket_id='purchase-receipts');
drop policy if exists "Authenticated users upload purchase receipts" on storage.objects;
create policy "Authenticated users upload purchase receipts" on storage.objects for insert to authenticated with check (bucket_id='purchase-receipts' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Owner deletes purchase receipts" on storage.objects;
create policy "Owner deletes purchase receipts" on storage.objects for delete to authenticated using (bucket_id='purchase-receipts' and public.is_owner());
