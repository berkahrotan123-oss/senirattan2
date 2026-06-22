-- Migration v22: role Fariz Sales, sektor penjualan, dan uang masuk penjualan

-- Perluas role profil agar mendukung sales
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles add constraint profiles_role_check check (role in ('secretary','owner','sales'));

create table if not exists public.sales_channels (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  note text,
  status text not null default 'Aktif' check (status in ('Aktif','Nonaktif')),
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.sales_incomes (
  id uuid primary key default gen_random_uuid(),
  transaction_date date not null,
  channel_id uuid not null references public.sales_channels(id),
  amount numeric(14,2) not null check (amount > 0),
  note text,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create index if not exists sales_channels_name_idx on public.sales_channels(name);
create index if not exists sales_incomes_date_idx on public.sales_incomes(transaction_date);
create index if not exists sales_incomes_channel_idx on public.sales_incomes(channel_id);

alter table public.sales_channels enable row level security;
alter table public.sales_incomes enable row level security;

grant select, insert, update, delete on public.sales_channels to authenticated;
grant select, insert, update, delete on public.sales_incomes to authenticated;

-- Sales staff dapat baca/input/update data sales. Delete hanya owner.
do $$
declare t text;
begin
  foreach t in array array['sales_channels','sales_incomes'] loop
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

-- Jalankan bagian ini setelah user Fariz dibuat di Authentication.
-- Ganti EMAIL_FARIZ dengan email login Fariz.
-- insert into public.profiles (id, full_name, role)
-- select id, 'Fariz', 'sales'
-- from auth.users
-- where email = 'EMAIL_FARIZ'
-- on conflict (id) do update set full_name = excluded.full_name, role = excluded.role;
