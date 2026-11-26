-- Run this AFTER the admin user logs in for the first time with +998941771247
-- This grants admin role to that phone number.

update public.profiles
set role = 'admin'
where phone = '+998941771247';

-- Verify:
-- select id, phone, role from public.profiles where phone = '+998941771247';
