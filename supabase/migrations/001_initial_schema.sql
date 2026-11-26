-- Enable extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- PROFILES
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  phone text unique not null,
  full_name text,
  avatar_url text,
  role text not null default 'customer' check (role in ('customer', 'driver', 'admin')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "Own profile read" on public.profiles for select using (auth.uid() = id);
create policy "Own profile update" on public.profiles for update using (auth.uid() = id);
create policy "Admin all profiles" on public.profiles for all using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- CATEGORIES
create table public.categories (
  id uuid primary key default uuid_generate_v4(),
  name_uz text not null,
  icon text not null,
  color text not null default '#6366F1',
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);
alter table public.categories enable row level security;
create policy "Public categories" on public.categories for select using (is_active = true);
create policy "Admin categories" on public.categories for all using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- DRIVERS
create table public.drivers (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid references public.profiles not null unique,
  vehicle_model text not null,
  vehicle_plate text not null,
  rating numeric(3,2) not null default 5.00,
  total_deliveries int not null default 0,
  is_online boolean not null default false,
  current_lat double precision,
  current_lng double precision,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.drivers enable row level security;
create policy "Driver own record" on public.drivers for select using (profile_id = auth.uid());
create policy "Driver update self" on public.drivers for update using (profile_id = auth.uid());
create policy "Admin drivers" on public.drivers for all using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));
create policy "Customer see online drivers" on public.drivers for select using (is_online = true);

-- ORDERS
create table public.orders (
  id uuid primary key default uuid_generate_v4(),
  order_number text not null unique default 'BK-' || upper(substring(gen_random_uuid()::text, 1, 6)),
  customer_id uuid references public.profiles not null,
  driver_id uuid references public.drivers,
  category_id uuid references public.categories not null,
  status text not null default 'pending' check (status in ('pending','accepted','picked_up','on_the_way','delivered','cancelled')),
  pickup_address text not null,
  pickup_lat double precision not null,
  pickup_lng double precision not null,
  delivery_address text not null,
  delivery_lat double precision not null,
  delivery_lng double precision not null,
  description text,
  price numeric(12,2) not null default 0,
  delivery_fee numeric(12,2) not null default 15000,
  total_price numeric(12,2) generated always as (price + delivery_fee) stored,
  estimated_minutes int,
  notes text,
  cancelled_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  delivered_at timestamptz
);
alter table public.orders enable row level security;
create policy "Customer own orders" on public.orders for select using (customer_id = auth.uid());
create policy "Customer create order" on public.orders for insert with check (customer_id = auth.uid());
create policy "Driver see pending" on public.orders for select using (status = 'pending');
create policy "Driver see assigned" on public.orders for select using (exists (select 1 from public.drivers d where d.id = orders.driver_id and d.profile_id = auth.uid()));
create policy "Driver update assigned" on public.orders for update using (exists (select 1 from public.drivers d where d.id = orders.driver_id and d.profile_id = auth.uid()));
create policy "Admin all orders" on public.orders for all using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- REVIEWS
create table public.reviews (
  id uuid primary key default uuid_generate_v4(),
  order_id uuid references public.orders not null unique,
  customer_id uuid references public.profiles not null,
  driver_id uuid references public.drivers not null,
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now()
);
alter table public.reviews enable row level security;
create policy "Customer create review" on public.reviews for insert with check (customer_id = auth.uid());
create policy "Public reviews" on public.reviews for select using (true);

-- NOTIFICATIONS
create table public.notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles not null,
  title text not null,
  body text not null,
  type text not null default 'info' check (type in ('info','order','promo','system')),
  is_read boolean not null default false,
  data jsonb,
  created_at timestamptz not null default now()
);
alter table public.notifications enable row level security;
create policy "Own notifications" on public.notifications for select using (user_id = auth.uid());
create policy "Mark read" on public.notifications for update using (user_id = auth.uid());

-- FUNCTIONS
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create trigger t_profiles_upd before update on public.profiles for each row execute function public.set_updated_at();
create trigger t_drivers_upd before update on public.drivers for each row execute function public.set_updated_at();
create trigger t_orders_upd before update on public.orders for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, phone, full_name, role)
  values (new.id, new.phone, coalesce(new.raw_user_meta_data->>'full_name', ''), coalesce(new.raw_user_meta_data->>'role', 'customer'));
  return new;
end; $$;

create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

-- SEED
insert into public.categories (name_uz, icon, color, sort_order) values
  ('Oziq-ovqat', '🛒', '#6366F1', 1),
  ('Dori-darmon', '💊', '#10B981', 2),
  ('Pochta / Paket', '📦', '#F59E0B', 3);

-- ADMIN SETUP (run after first login with +998941771247):
-- update public.profiles set role='admin' where phone='+998941771247';
