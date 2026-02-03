# Demo Users for Connection Lenses Testing

## Overview
10 demo users created with complete profiles, photos, and lens assignments for testing the Connection Lenses feature.

---

## Demo Users Configuration

### 1. Emma (Calm & Cozy)
- **Age:** 28 | **City:** Portland
- **Lenses:** Calm & Cozy, Creative & Curious, Healthy & Grounded
- **Interests:** Reading, Coffee, Meditation, Yoga, Writing, Art, Museums, Books, Board Games, Baking
- **Best Match For:** Users who also select "Calm & Cozy"

### 2. Jake (Active & Energetic)
- **Age:** 26 | **City:** Denver
- **Lenses:** Active & Energetic, Ambitious & Driven, Healthy & Grounded
- **Interests:** Gym, Running, Hiking, Cycling, Rock Climbing, Swimming, Tennis, Fitness, Adventure, Sports
- **Best Match For:** Users who select "Active & Energetic"

### 3. Sarah (Values & Roots)
- **Age:** 31 | **City:** Nashville
- **Lenses:** Values & Roots, Healthy & Grounded, Calm & Cozy
- **Interests:** Volunteering, Sustainability, Politics, Philosophy, Religion, History, Family, Community, Tradition, Faith
- **Best Match For:** Users who select "Values & Roots"

### 4. Mia (Creative & Curious)
- **Age:** 25 | **City:** Austin
- **Lenses:** Creative & Curious, Humorous & Playful, Social & Spontaneous
- **Interests:** Art, Music, Photography, Writing, Design, Fashion, Museums, Theater, Dance, Creativity
- **Best Match For:** Users who select "Creative & Curious"

### 5. Alex (Social & Spontaneous)
- **Age:** 27 | **City:** Miami
- **Lenses:** Social & Spontaneous, Active & Energetic, Humorous & Playful
- **Interests:** Parties, Festivals, Concerts, Dining Out, Networking, Hosting, Brunch, Travel, Socializing, Events
- **Best Match For:** Users who select "Social & Spontaneous"

### 6. Olivia (Healthy & Grounded)
- **Age:** 29 | **City:** Seattle
- **Lenses:** Healthy & Grounded, Calm & Cozy, Values & Roots
- **Interests:** Yoga, Meditation, Mindfulness, Nature, Sustainability, Volunteering, Cooking, Wellness, Balance, Health
- **Best Match For:** Users who select "Healthy & Grounded"

### 7. David (Ambitious & Driven)
- **Age:** 30 | **City:** San Francisco
- **Lenses:** Ambitious & Driven, Active & Energetic, Values & Roots
- **Interests:** Technology, Science, Business, Networking, Learning, Languages, Leadership, Entrepreneurship, Career, Ambition
- **Best Match For:** Users who select "Ambitious & Driven"

### 8. Luna (Humorous & Playful)
- **Age:** 26 | **City:** Los Angeles
- **Lenses:** Humorous & Playful, Social & Spontaneous, Creative & Curious
- **Interests:** Comedy, Gaming, Board Games, Concerts, Festivals, Netflix, Movies, Travel, Humor, Fun
- **Best Match For:** Users who select "Humorous & Playful"

### 9. Chris (Balanced Mix)
- **Age:** 28 | **City:** Chicago
- **Lenses:** Active & Energetic, Creative & Curious, Calm & Cozy
- **Interests:** Reading, Gym, Travel, Music, Cooking, Photography, Art, Hiking, Coffee, Movies
- **Best Match For:** Users who select "Creative & Curious" or "Calm & Cozy"

### 10. Jordan (Creative/Active Mix)
- **Age:** 27 | **City:** Brooklyn
- **Lenses:** Creative & Curious, Active & Energetic, Healthy & Grounded
- **Interests:** Art, Music, Yoga, Running, Writing, Coffee, Creativity, Wellness, Photography, Travel
- **Best Match For:** Users who select "Creative & Curious" or "Active & Energetic"

---

## Testing Scenarios

### Scenario 1: Test "Calm & Cozy" Lens
**Your lenses:** Calm & Cozy, Creative & Curious, Healthy & Grounded

**Expected Top Matches:**
1. Emma (Calm & Cozy, Creative & Curious, Healthy & Grounded) - 100% overlap
2. Olivia (Healthy & Grounded, Calm & Cozy) - 2/3 overlap
3. Chris (Calm & Cozy) - 1/3 overlap

### Scenario 2: Test "Active & Energetic" Lens
**Your lenses:** Active & Energetic, Ambitious & Driven, Social & Spontaneous

**Expected Top Matches:**
1. Jake (Active & Energetic, Ambitious & Driven, Healthy & Grounded) - 2/3 overlap
2. Alex (Social & Spontaneous, Active & Energetic) - 2/3 overlap
3. Jordan (Creative & Curious, Active & Energetic) - 1/3 overlap

### Scenario 3: Test "Creative & Curious" Lens
**Your lenses:** Creative & Curious, Humorous & Playful, Social & Spontaneous

**Expected Top Matches:**
1. Mia (Creative & Curious, Humorous & Playful, Social & Spontaneous) - 100% overlap
2. Luna (Humorous & Playful, Social & Spontaneous, Creative & Curious) - 100% overlap
3. Chris (Active & Energetic, Creative & Curious, Calm & Cozy) - 1/3 overlap

### Scenario 4: Test "Social & Spontaneous" Lens
**Your lenses:** Social & Spontaneous, Humorous & Playful, Active & Energetic

**Expected Top Matches:**
1. Alex (Social & Spontaneous, Active & Energetic, Humorous & Playful) - 100% overlap
2. Luna (Humorous & Playful, Social & Spontaneous, Creative & Curious) - 2/3 overlap
3. Mia (Creative & Curious, Humorous & Playful, Social & Spontaneous) - 100% overlap

---

## How to Apply Demo Data

### Step 1: Apply Migration 014 (Create Demo Users)
Run in Supabase SQL Editor:
```
C:\Users\shahb\myApplications\7Eps\supabase\migrations\014_create_demo_users.sql
```

### Step 2: Apply Migration 015 (Assign Lenses)
Run in Supabase SQL Editor:
```
C:\Users\shahb\myApplications\7Eps\supabase\migrations\015_assign_lenses_to_demo_users.sql
```

### Step 3: Fix Daily Edition Function
Run the fix SQL provided earlier to fix the jsonb casting error

### Step 4: Test the App!

---

## Verification Queries

### Check Demo Users Created
```sql
SELECT name, age, city, jsonb_array_length(interests) as interest_count
FROM public.profiles
WHERE user_id::text LIKE '%1111%'
   OR user_id::text LIKE '%2222%'
   OR user_id::text LIKE '%3333%'
ORDER BY name;
```

### Check Photos Uploaded
```sql
SELECT p.name, COUNT(pp.id) as photo_count
FROM public.profiles p
LEFT JOIN public.profile_photos pp ON p.user_id = pp.user_id
WHERE p.user_id::text LIKE '%1111%'
   OR p.user_id::text LIKE '%2222%'
   OR p.user_id::text LIKE '%3333%'
   OR p.user_id::text LIKE '%4444%'
   OR p.user_id::text LIKE '%5555%'
GROUP BY p.name;
```

### Check Lens Assignments
```sql
SELECT
  p.name,
  l1.name AS lens_1,
  l2.name AS lens_2,
  l3.name AS lens_3
FROM public.profiles p
LEFT JOIN public.user_lenses ul1 ON p.user_id = ul1.user_id AND ul1.rank = 1
LEFT JOIN public.lenses l1 ON ul1.lens_id = l1.id
LEFT JOIN public.user_lenses ul2 ON p.user_id = ul2.user_id AND ul2.rank = 2
LEFT JOIN public.lenses l2 ON ul2.lens_id = l2.id
LEFT JOIN public.user_lenses ul3 ON p.user_id = ul3.user_id AND ul3.rank = 3
LEFT JOIN public.lenses l3 ON ul3.lens_id = l3.id
WHERE p.user_id::text SIMILAR TO '%(1111|2222|3333|4444|5555)%'
ORDER BY p.name;
```

---

## Photo URLs Used

All demo users use Unsplash placeholder images. Replace these with real photos for production:

- **Emma:** https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400
- **Jake:** https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400
- **Sarah:** https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400
- **Mia:** https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400
- **Alex:** https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400
- **Olivia:** https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400
- **David:** https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400
- **Luna:** https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400
- **Chris:** https://images.unsplash.com/photo-1519085360753-af0119f5cbe7?w=400
- **Jordan:** https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400
