-- Profiles: one row per signed-in user (created automatically at sign-up).
-- The phone and role are private; other users never read this table directly
-- (contact details are revealed later through a dedicated function, D3).

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text,
  role text check (role in ('student', 'employer')),
  locale text check (locale in ('fr', 'ar')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- A user reads only their own profile.
create policy profiles_select_own on public.profiles
  for select to authenticated
  using ((select auth.uid()) = id);

-- A user may only change their language directly; the role goes through
-- set_role() and the phone is copied from auth.
create policy profiles_update_own on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant update (locale) on public.profiles to authenticated;

-- Keep updated_at current.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function public.touch_updated_at();

-- Create the profile when a user signs up (phone OTP).
create schema if not exists private;

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, phone)
  values (new.id, new.phone)
  on conflict (id) do nothing;
  return new;
end;
$$;

revoke execute on function private.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- Choose the role once (A6). Fixed for v1: fails if already set.
create or replace function public.set_role(new_role text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := (select auth.uid());
begin
  if uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if new_role not in ('student', 'employer') then
    raise exception 'invalid role' using errcode = '22023';
  end if;
  update public.profiles
     set role = new_role
   where id = uid and role is null;
  if not found then
    raise exception 'role already chosen' using errcode = 'P0001';
  end if;
end;
$$;

revoke execute on function public.set_role(text) from public, anon;
grant execute on function public.set_role(text) to authenticated;
