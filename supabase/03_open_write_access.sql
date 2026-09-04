-- Removes the password-gated write path in favor of fully open access:
-- anyone who can reach the page can view AND edit. Run this once in the
-- SQL Editor of the existing project (after 01_setup.sql / 02_seed.sql).

-- Drop the now-unused password-gated RPC functions and secret store.
drop function if exists upsert_event(text, text, jsonb);
drop function if exists delete_event(text, text);
drop table if exists app_secrets;

-- Replace the read-only policy set with full open CRUD.
drop policy if exists "public read" on events;
create policy "public read" on events for select using (true);

drop policy if exists "public insert" on events;
create policy "public insert" on events for insert with check (true);

drop policy if exists "public update" on events;
create policy "public update" on events for update using (true) with check (true);

drop policy if exists "public delete" on events;
create policy "public delete" on events for delete using (true);

grant select, insert, update, delete on events to anon, authenticated;
