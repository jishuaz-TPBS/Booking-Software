# Twist Booking Board

Photo booth event tracker, hosted as a static page on GitHub Pages with
Supabase as the database. Anyone with the link can view the board;
editing requires a shared password checked server-side by Supabase.

**Live site:** https://jishuaz-tpbs.github.io/Booking-Software/
**Supabase project:** `twist-booking-board` in the "Twist Photo Booths"
org (project ref `mklxquarwjyyegkxtyvv`)

The edit password is intentionally **not** written here — this repo is
public, and anything in it is world-readable. It was set when
`01_setup.sql` ran; to see or change it, open Supabase's Table Editor
on the `app_secrets` table (never commit it to this repo).

## Already set up

This repo, the GitHub Pages deployment, and the Supabase project were
all provisioned already — `index.html` has the real Supabase URL and
publishable key filled in, and `events` has all 59 original bookings
loaded. Nothing below needs to be redone; it's kept for reference if
you ever need to recreate the project from scratch.

## One-time setup (reference only)

### 1. Supabase

1. Create a project at https://supabase.com (or use an existing one).
2. Open **SQL Editor > New query**, paste in `supabase/01_setup.sql`.
   Before running it, change the placeholder password on this line:
   ```sql
   insert into app_secrets (key, value) values ('edit_password', 'CHANGE_ME_BEFORE_RUNNING')
   ```
   to whatever password your team should use to unlock editing. Run it.
3. Open a new query, paste in `supabase/02_seed.sql`, and run it. This
   loads the 59 existing bookings into the `events` table.
4. Go to **Settings > API Keys** and copy the **Project URL** and the
   **Publishable key**.
5. In `index.html`, near the top of the `<body>`, fill in:
   ```html
   window.SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
   window.SUPABASE_ANON_KEY = "YOUR_SUPABASE_PUBLISHABLE_KEY";
   ```
   That key is safe to publish — Row Level Security and the
   password-gated RPC functions in `01_setup.sql` are what actually
   control access, not the key itself.

### 2. GitHub Pages

1. Push this folder to a GitHub repo.
2. GitHub Pages auto-enables on a public repo the first time you push
   an `index.html` at the root. If it doesn't, go to **Settings >
   Pages**, set **Source** to "Deploy from a branch", branch `main`,
   folder `/ (root)`, and save.
3. GitHub gives you a URL like `https://<user>.github.io/<repo>/` —
   that's the live board.

## How editing works

- The page is read-only until someone clicks **"🔒 Unlock editing"**
  and enters the shared password.
- The password is never checked in the browser — it's sent with every
  save to a Supabase function (`upsert_event` / `delete_event`) that
  verifies it server-side before touching the `events` table.
- Multiple people can have the page open at once; changes sync live
  via Supabase Realtime.
- To change the password later, update the `app_secrets` row in
  Supabase (Table Editor or SQL Editor) — no redeploy needed.
