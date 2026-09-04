-- Twist Booking Board — Supabase schema
-- Run this once in your Supabase project's SQL Editor (Project > SQL Editor > New query > Run).

-- 1. Events table (one row per booking, full record kept as JSON for simplicity)
create table if not exists events (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table events enable row level security;

-- Anyone can read the board (page is publicly reachable on GitHub Pages)
drop policy if exists "public read" on events;
create policy "public read" on events for select using (true);

-- No direct insert/update/delete policies on purpose — all writes must go
-- through the password-checked RPC functions below.

-- 2. Secret store for the shared edit password. Never selectable by anon/authenticated directly.
create table if not exists app_secrets (
  key text primary key,
  value text not null
);
alter table app_secrets enable row level security;
-- (no policies added => anon/authenticated get zero direct access; only
-- the SECURITY DEFINER functions below can read it)

-- Set your own shared edit password here before running the rest of the script:
insert into app_secrets (key, value) values ('edit_password', 'CHANGE_ME_BEFORE_RUNNING')
  on conflict (key) do update set value = excluded.value;

-- 3. Password-gated write functions (SECURITY DEFINER = runs with owner
-- privileges, so it can read app_secrets even though callers can't).
create or replace function upsert_event(p_password text, p_id text, p_data jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pass text;
begin
  select value into v_pass from app_secrets where key = 'edit_password';
  if v_pass is null or p_password is null or p_password <> v_pass then
    raise exception 'invalid password' using errcode = '28000';
  end if;
  insert into events (id, data, updated_at) values (p_id, p_data, now())
    on conflict (id) do update set data = excluded.data, updated_at = now();
end;
$$;

create or replace function delete_event(p_password text, p_id text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pass text;
begin
  select value into v_pass from app_secrets where key = 'edit_password';
  if v_pass is null or p_password is null or p_password <> v_pass then
    raise exception 'invalid password' using errcode = '28000';
  end if;
  delete from events where id = p_id;
end;
$$;

-- 4. Grants: table-level access kept minimal (RLS + RPC do the real work).
grant usage on schema public to anon, authenticated;
grant select on events to anon, authenticated;
revoke insert, update, delete on events from anon, authenticated;
revoke all on app_secrets from anon, authenticated;
grant execute on function upsert_event(text, text, jsonb) to anon, authenticated;
grant execute on function delete_event(text, text) to anon, authenticated;
