# How to Apply All Database Migrations

## Quick Summary
1. Apply 4 core migrations (Lenses, Scoring, Auto-detection)
2. Create 10 demo users in Auth UI
3. Apply 1 demo setup migration (profiles + photos + lenses)
4. Done!

---

## Step 1: Apply Core Lens Migrations

Go to: https://supabase.com/dashboard/project/7eps/sql

### 1.1 Apply Migration 011 (Lens Tables)
1. Click "New Query"
2. Copy contents of: `supabase/migrations/011_add_connection_lenses.sql`
3. Paste and click "Run"

**Verify:**
```sql
SELECT COUNT(*) FROM public.lenses; -- Should return 8
```

---

### 1.2 Apply Migration 012 (Weighted Scoring)
1. Click "New Query"
2. Copy contents of: `supabase/migrations/012_update_daily_edition_with_lenses.sql`
3. Paste and click "Run"

**If you get an error about jsonb casting**, apply this fix instead:
1. Copy contents of: `supabase/migrations/013_fix_daily_edition_function.sql`
2. Run that

---

### 1.3 Apply Migration 016 (Auto Lens Detection)
1. Click "New Query"
2. Copy contents of: `supabase/migrations/016_auto_lens_detection.sql`
3. Paste and click "Run"

---

## Step 2: Create Demo Users in Auth UI

Go to: https://supabase.com/dashboard/project/7eps/auth/users

Click "Add user" and create these 10 users (password: `demo12345` for all):

| Email | Name | Auto Confirm |
|-------|------|--------------|
| emma@demo.com | Emma | ✅ Checked |
| jake@demo.com | Jake | ✅ Checked |
| sarah@demo.com | Sarah | ✅ Checked |
| mia@demo.com | Mia | ✅ Checked |
| alex@demo.com | Alex | ✅ Checked |
| olivia@demo.com | Olivia | ✅ Checked |
| david@demo.com | David | ✅ Checked |
| luna@demo.com | Luna | ✅ Checked |
| chris@demo.com | Chris | ✅ Checked |
| jordan@demo.com | Jordan | ✅ Checked |

**Important:** Leave "Auto Confirm User" CHECKED

---

## Step 3: Apply Demo Setup Migration

Go back to: https://supabase.com/dashboard/project/7eps/sql

1. Click "New Query"
2. Copy contents of: `supabase/migrations/017_complete_demo_setup.sql`
3. Paste and click "Run"

**This one migration creates:**
- ✅ 10 complete profiles with interests and bios
- ✅ 30 profile photos (3 per user)
- ✅ 30 lens assignments (3 per user)

---

## Step 4: Verify Everything

Run this query to verify:

```sql
SELECT
  p.name,
  p.city,
  l1.name AS lens_1,
  l2.name AS lens_2,
  l3.name AS lens_3,
  (SELECT COUNT(*) FROM public.profile_photos WHERE user_id = p.user_id) as photos
FROM public.profiles p
LEFT JOIN public.user_lenses ul1 ON p.user_id = ul1.user_id AND ul1.rank = 1
LEFT JOIN public.lenses l1 ON ul1.lens_id = l1.id
LEFT JOIN public.user_lenses ul2 ON p.user_id = ul2.user_id AND ul2.rank = 2
LEFT JOIN public.lenses l2 ON ul2.lens_id = l2.id
LEFT JOIN public.user_lenses ul3 ON p.user_id = ul3.user_id AND ul3.rank = 3
LEFT JOIN public.lenses l3 ON ul3.lens_id = l3.id
WHERE p.email IN (
  'emma@demo.com', 'jake@demo.com', 'sarah@demo.com', 'mia@demo.com',
  'alex@demo.com', 'olivia@demo.com', 'david@demo.com', 'luna@demo.com',
  'chris@demo.com', 'jordan@demo.com'
)
ORDER BY p.name;
```

**Expected output:** 10 rows, each with 3 lenses and 3 photos

---

## What Each Demo User Represents

| User | Lenses | Best For Testing |
|------|--------|------------------|
| Emma | Calm & Cozy, Creative, Healthy | Introvert matching |
| Jake | Active, Ambitious, Healthy | Fitness matching |
| Sarah | Values, Healthy, Calm | Faith/tradition matching |
| Mia | Creative, Humorous, Social | Artsy matching |
| Alex | Social, Active, Humorous | Extrovert matching |
| Olivia | Healthy, Calm, Values | Wellness matching |
| David | Ambitious, Active, Values | Career matching |
| Luna | Humorous, Social, Creative | Fun matching |
| Chris | Active, Creative, Calm | Balanced user |
| Jordan | Creative, Active, Healthy | Mixed vibes |

---

## Once Complete

Let me know when you've:
1. ✅ Applied migrations 011, 012/013, 016
2. ✅ Created 10 users in Auth UI
3. ✅ Applied migration 017
4. ✅ Verified data

Then I'll start the Flutter app and help you test the complete Connection Lenses feature!

---

## Troubleshooting

**Error: "foreign key constraint"**
- Make sure you created users in Auth UI FIRST
- Don't skip Step 2!

**Error: "cannot cast type jsonb[] to jsonb"**
- Use migration 013 instead of 012

**Users not showing up**
- Check email spelling matches exactly (emma@demo.com, not Emma@demo.com)
- Make sure "Auto Confirm User" was checked

**No lenses assigned**
- Run migration 011 first to create the lenses table
- Then run 017
