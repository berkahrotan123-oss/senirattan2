-- Migration v20 - DP Supplier / Down Payment Barang Masuk
-- Jalankan sekali di Supabase SQL Editor sebelum upload versi v20.

create table if not exists public.supplier_down_payments (
  id uuid primary key default gen_random_uuid(),
  transaction_date date not null,
  supplier_id uuid not null references public.suppliers(id),
  amount numeric(14,2) not null check (amount > 0),
  note text,
  applied_purchase_id uuid references public.purchases(id) on delete set null,
  applied_amount numeric(14,2) not null default 0 check (applied_amount >= 0),
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create index if not exists supplier_down_payments_date_idx on public.supplier_down_payments(transaction_date);
create index if not exists supplier_down_payments_supplier_idx on public.supplier_down_payments(supplier_id);
create index if not exists supplier_down_payments_applied_idx on public.supplier_down_payments(applied_purchase_id);

alter table public.supplier_down_payments enable row level security;

drop policy if exists "Staff read" on public.supplier_down_payments;
create policy "Staff read" on public.supplier_down_payments
for select to authenticated using (true);

drop policy if exists "Staff insert" on public.supplier_down_payments;
create policy "Staff insert" on public.supplier_down_payments
for insert to authenticated with check (true);

drop policy if exists "Staff update" on public.supplier_down_payments;
create policy "Staff update" on public.supplier_down_payments
for update to authenticated using (true) with check (true);

drop policy if exists "Owner delete" on public.supplier_down_payments;
create policy "Owner delete" on public.supplier_down_payments
for delete to authenticated using (public.is_owner());

grant select, insert, update, delete on public.supplier_down_payments to authenticated;
