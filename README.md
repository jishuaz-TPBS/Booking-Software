# Twist Booking Board

Photo booth event tracker, hosted as a static page on GitHub Pages with
Supabase as the database. It's fully open: anyone with the link can
both view and edit the board — there is no password or login.

**Live site:** https://jishuaz-tpbs.github.io/Booking-Software/
**Supabase project:** `twist-booking-board` in the "Twist Photo Booths"
org (project ref `mklxquarwjyyegkxtyvv`)

Keep the link itself as the access control — anyone you send it to can
change or delete bookings, with no confirmation step.

## Already set up

This repo, the GitHub Pages deployment, and the Supabase project were
all provisioned already — `index.html` has the real Supabase URL and
publishable key filled in, and `events` has all 59 original bookings
loaded. Nothing below needs to be redone; it's kept for reference if
you ever need to recreate the project from scratch.

## One-time setup (reference only)

### 1. Supabase

1. Create a project at https://supabase.com (or use an existing one).
2. Open **SQL Editor > New query**, paste in `supabase/01_setup.sql`
   and run it — this creates the `events` table.
3. Open a new query, paste in `supabase/02_seed.sql`, and run it. This
   loads the 59 existing bookings into the `events` table.
4. Open a new query, paste in `supabase/03_open_write_access.sql`, and
   run it — this grants open read/write access to anyone with the
   publishable key (used instead of the password-gated setup that
   `01_setup.sql` originally created).
5. Go to **Settings > API Keys** and copy the **Project URL** and the
   **Publishable key**.
6. In `index.html`, near the top of the `<body>`, fill in:
   ```html
   window.SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
   window.SUPABASE_ANON_KEY = "YOUR_SUPABASE_PUBLISHABLE_KEY";
   ```

### 2. GitHub Pages

1. Push this folder to a GitHub repo.
2. GitHub Pages auto-enables on a public repo the first time you push
   an `index.html` at the root. If it doesn't, go to **Settings >
   Pages**, set **Source** to "Deploy from a branch", branch `main`,
   folder `/ (root)`, and save.
3. GitHub gives you a URL like `https://<user>.github.io/<repo>/` —
   that's the live board.

## How editing works

- No password, no login — the "+ Add event" button and every field on
  the board are live and save automatically as soon as Supabase
  connects (a banner shows if the connection fails).
- Multiple people can have the page open at once; changes sync live
  via Supabase Realtime.
- Access control lives entirely in who has the link. If that ever
  needs to change, `supabase/03_open_write_access.sql` shows the RLS
  policies to tighten back up.
