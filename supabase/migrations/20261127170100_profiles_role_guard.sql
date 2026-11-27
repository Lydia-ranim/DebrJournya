-- Replace the set_role() RPC (a SECURITY DEFINER function flagged by the
-- advisor) with a column grant + a guard trigger: users set their own role
-- once (A6); it can't change afterwards, and the phone is never edited.

drop function public.set_role(text);

grant update (role) on public.profiles to authenticated;

create or replace function public.guard_profile_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.role is not null and new.role is distinct from old.role then
    raise exception 'role already chosen' using errcode = 'P0001';
  end if;
  if new.phone is distinct from old.phone and current_user = 'authenticated' then
    raise exception 'phone cannot be changed here' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger profiles_guard_update
  before update on public.profiles
  for each row execute function public.guard_profile_update();
