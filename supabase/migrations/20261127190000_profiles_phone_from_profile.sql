-- Sign-in is now e-mail / Google / Facebook: the phone is typed in the
-- profile (B1 / C1) and kept private until an application is accepted.
alter table public.profiles
  add constraint profiles_phone_format
  check (phone is null or phone ~ '^\+213[567][0-9]{8}$');

grant update (phone) on public.profiles to authenticated;

create or replace function public.guard_profile_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.role is not null and new.role is distinct from old.role then
    raise exception 'role already chosen' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

-- New users no longer carry a phone from auth.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;
