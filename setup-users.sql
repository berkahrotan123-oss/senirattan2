-- 1. Buat akun Aan dan Febri lebih dahulu di Supabase > Authentication > Users.
-- 2. Ganti EMAIL_AAN dan EMAIL_FEBRI dengan email login yang sebenarnya.
-- 3. Jalankan query ini di SQL Editor.

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
