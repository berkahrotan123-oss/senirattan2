-- Jalankan file ini pada project Supabase yang SUDAH memakai versi sebelumnya.
alter table public.purchases add column if not exists amount numeric(14,2);
alter table public.purchases add column if not exists receipt_path text;
update public.purchases set amount = coalesce(amount, qty * unit_price, 0);
alter table public.purchases alter column amount set not null;
alter table public.purchases alter column item drop not null;
alter table public.purchases alter column qty drop not null;
alter table public.purchases alter column unit drop not null;
alter table public.purchases alter column unit_price drop not null;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('purchase-receipts','purchase-receipts',false,5242880,array['image/jpeg','image/png','image/webp','application/pdf'])
on conflict (id) do update set public=false, file_size_limit=5242880, allowed_mime_types=excluded.allowed_mime_types;

drop policy if exists "Authenticated users read purchase receipts" on storage.objects;
create policy "Authenticated users read purchase receipts" on storage.objects for select to authenticated using (bucket_id='purchase-receipts');
drop policy if exists "Authenticated users upload purchase receipts" on storage.objects;
create policy "Authenticated users upload purchase receipts" on storage.objects for insert to authenticated with check (bucket_id='purchase-receipts' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Owner deletes purchase receipts" on storage.objects;
create policy "Owner deletes purchase receipts" on storage.objects for delete to authenticated using (bucket_id='purchase-receipts' and public.is_owner());
