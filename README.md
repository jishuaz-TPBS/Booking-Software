# Twist Booking Board

Photo booth event tracker, hosted as a static page on GitHub Pages with
Supabase as the database. Anyone with the link can view the board;
editing requires a shared password checked server-side by Supabase.

## One-time setup

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
4. Go to **Settings > API** and copy the **Project URL** and the
   **anon public** key.
5. In `index.html`, near the top of the `<body>`, fill in:
   ```html
   window.SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
   window.SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
   ```
   The anon key is safe to publish — Row Level Security and the
   password-gated RPC functions in `01_setup.sql` are what actually
   control access, not the key itself.

### 2. GitHub Pages

1. Push this folder to a GitHub repo (see chat for exact commands).
2. In the repo, go to **Settings > Pages**, set **Source** to
   "Deploy from a branch", branch `main`, folder `/ (root)`. Save.
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
