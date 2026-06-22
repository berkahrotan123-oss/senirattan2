-- Jalankan setelah membuat 3 user di Supabase Authentication.
-- Ganti email di bawah dengan email login sebenarnya.

insert into public.profiles (id, full_name, role)
select id, 'Aan', 'secretary'
from auth.users
where email = 'EMAIL_AAN'
on conflict (id) do update
set full_name = excluded.full_name, role = excluded.role;

insert into public.profiles (id, full_name, role)
select id, 'Febri', 'owner'
from auth.users
where email = 'EMAIL_FEBRI'
on conflict (id) do update
set full_name = excluded.full_name, role = excluded.role;

insert into public.profiles (id, full_name, role)
select id, 'Fariz', 'sales'
from auth.users
where email = 'EMAIL_FARIZ'
on conflict (id) do update
set full_name = excluded.full_name, role = excluded.role;
