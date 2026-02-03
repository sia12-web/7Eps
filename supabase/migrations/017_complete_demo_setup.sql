-- ============================================================================
-- COMPLETE DEMO USER SETUP (With Email Lookup)
-- ============================================================================
-- This migration creates complete demo users with profiles, photos, and lenses
-- IMPORTANT: You must create users in Supabase Auth UI FIRST!
--
-- Create these 10 users at: https://supabase.com/dashboard/project/7eps/auth/users
-- Email format: [name]@demo.com | Password: demo12345
-- Users: emma, jake, sarah, mia, alex, olivia, david, luna, chris, jordan
-- ============================================================================

-- ============================================================================
-- PART 1: CREATE PROFILES (finds users by email from Auth)
-- ============================================================================

-- EMMA: Calm & Cozy
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'Emma',
  28,
  'Portland',
  '[{"name": "Reading"}, {"name": "Coffee"}, {"name": "Meditation"}, {"name": "Yoga"}, {"name": "Writing"}, {"name": "Art"}, {"name": "Museums"}, {"name": "Books"}, {"name": "Board Games"}, {"name": "Baking"}]'::jsonb,
  'I love quiet mornings with coffee and a good book. Looking for someone who enjoys cozy evenings and deep conversations.',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'emma@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- JAKE: Active & Energetic
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'Jake',
  26,
  'Denver',
  '[{"name": "Gym"}, {"name": "Running"}, {"name": "Hiking"}, {"name": "Cycling"}, {"name": "Rock Climbing"}, {"name": "Swimming"}, {"name": "Tennis"}, {"name": "Fitness"}, {"name": "Adventure"}, {"name": "Sports"}]'::jsonb,
  'Early riser always looking for the next adventure. Let me show you my favorite hiking trails!',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'jake@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- SARAH: Values & Roots
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'Sarah',
  31,
  'Nashville',
  '[{"name": "Volunteering"}, {"name": "Sustainability"}, {"name": "Politics"}, {"name": "Philosophy"}, {"name": "Religion"}, {"name": "History"}, {"name": "Family"}, {"name": "Community"}, {"name": "Tradition"}, {"name": "Faith"}]'::jsonb,
  'Family-oriented and grounded in my faith. Looking for someone who values tradition and community service.',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'sarah@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- MIA: Creative & Curious
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'Mia',
  25,
  'Austin',
  '[{"name": "Art"}, {"name": "Music"}, {"name": "Photography"}, {"name": "Writing"}, {"name": "Design"}, {"name": "Fashion"}, {"name": "Museums"}, {"name": "Theater"}, {"name": "Dance"}, {"name": "Creativity"}]'::jsonb,
  'Always creating something new. Let me capture your beauty through my lens or get lost in art galleries together.',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'mia@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- ALEX: Social & Spontaneous
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'Alex',
  27,
  'Miami',
  '[{"name": "Parties"}, {"name": "Festivals"}, {"name": "Concerts"}, {"name": "Dining Out"}, {"name": "Networking"}, {"name": "Hosting"}, {"name": "Brunch"}, {"name": "Travel"}, {"name": "Socializing"}, {"name": "Events"}]'::jsonb,
  'Life of the party looking for my dance partner. Spontaneous road trips and late-night convos are my love language.',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'alex@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- OLIVIA: Healthy & Grounded
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'Olivia',
  29,
  'Seattle',
  '[{"name": "Yoga"}, {"name": "Meditation"}, {"name": "Mindfulness"}, {"name": "Nature"}, {"name": "Sustainability"}, {"name": "Volunteering"}, {"name": "Cooking"}, {"name": "Wellness"}, {"name": "Balance"}, {"name": "Health"}]'::jsonb,
  'Finding balance in mindfulness and nature. Looking for someone who values wellness and low-drama connections.',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'olivia@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- DAVID: Ambitious & Driven
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'David',
  30,
  'San Francisco',
  '[{"name": "Technology"}, {"name": "Science"}, {"name": "Business"}, {"name": "Networking"}, {"name": "Learning"}, {"name": "Languages"}, {"name": "Leadership"}, {"name": "Entrepreneurship"}, {"name": "Career"}, {"name": "Ambition"}]'::jsonb,
  'Building the future one startup at a time. Looking for someone who shares my drive and passion for growth.',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'david@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- LUNA: Humorous & Playful
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'Luna',
  26,
  'Los Angeles',
  '[{"name": "Comedy"}, {"name": "Gaming"}, {"name": "Board Games"}, {"name": "Concerts"}, {"name": "Festivals"}, {"name": "Netflix"}, {"name": "Movies"}, {"name": "Travel"}, {"name": "Humor"}, {"name": "Fun"}]'::jsonb,
  'Professional meme dealer and laughter enthusiast. Looking for someone who doesn''t take life too seriously.',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'luna@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- CHRIS: Balanced Mix
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'Chris',
  28,
  'Chicago',
  '[{"name": "Reading"}, {"name": "Gym"}, {"name": "Travel"}, {"name": "Music"}, {"name": "Cooking"}, {"name": "Photography"}, {"name": "Art"}, {"name": "Hiking"}, {"name": "Coffee"}, {"name": "Movies"}]'::jsonb,
  'Equal parts adventure and chill. I''m just as happy hiking a mountain as I am with a book at a coffee shop.',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'chris@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- JORDAN: Creative/Active Mix
INSERT INTO public.profiles (user_id, name, age, city, interests, bio, created_at, updated_at)
SELECT
  id,
  'Jordan',
  27,
  'Brooklyn',
  '[{"name": "Art"}, {"name": "Music"}, {"name": "Yoga"}, {"name": "Running"}, {"name": "Writing"}, {"name": "Coffee"}, {"name": "Creativity"}, {"name": "Wellness"}, {"name": "Photography"}, {"name": "Travel"}]'::jsonb,
  'Creative soul with an active streak. Let me write you a song after our morning run.',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'jordan@demo.com'
ON CONFLICT (user_id) DO UPDATE SET
  name = EXCLUDED.name,
  age = EXCLUDED.age,
  city = EXCLUDED.city,
  interests = EXCLUDED.interests,
  bio = EXCLUDED.bio,
  updated_at = NOW();

-- ============================================================================
-- PART 2: ADD PHOTOS FOR ALL DEMO USERS
-- ============================================================================

-- Emma's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400', 1, NOW()
FROM auth.users WHERE email = 'emma@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400', 2, NOW()
FROM auth.users WHERE email = 'emma@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400', 3, NOW()
FROM auth.users WHERE email = 'emma@demo.com'
ON CONFLICT DO NOTHING;

-- Jake's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 1, NOW()
FROM auth.users WHERE email = 'jake@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400', 2, NOW()
FROM auth.users WHERE email = 'jake@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400', 3, NOW()
FROM auth.users WHERE email = 'jake@demo.com'
ON CONFLICT DO NOTHING;

-- Sarah's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400', 1, NOW()
FROM auth.users WHERE email = 'sarah@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400', 2, NOW()
FROM auth.users WHERE email = 'sarah@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400', 3, NOW()
FROM auth.users WHERE email = 'sarah@demo.com'
ON CONFLICT DO NOTHING;

-- Mia's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400', 1, NOW()
FROM auth.users WHERE email = 'mia@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400', 2, NOW()
FROM auth.users WHERE email = 'mia@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400', 3, NOW()
FROM auth.users WHERE email = 'mia@demo.com'
ON CONFLICT DO NOTHING;

-- Alex's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400', 1, NOW()
FROM auth.users WHERE email = 'alex@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400', 2, NOW()
FROM auth.users WHERE email = 'alex@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1519085360753-af0119f5cbe7?w=400', 3, NOW()
FROM auth.users WHERE email = 'alex@demo.com'
ON CONFLICT DO NOTHING;

-- Olivia's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400', 1, NOW()
FROM auth.users WHERE email = 'olivia@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=400', 2, NOW()
FROM auth.users WHERE email = 'olivia@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=400', 3, NOW()
FROM auth.users WHERE email = 'olivia@demo.com'
ON CONFLICT DO NOTHING;

-- David's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400', 1, NOW()
FROM auth.users WHERE email = 'david@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', 2, NOW()
FROM auth.users WHERE email = 'david@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400', 3, NOW()
FROM auth.users WHERE email = 'david@demo.com'
ON CONFLICT DO NOTHING;

-- Luna's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400', 1, NOW()
FROM auth.users WHERE email = 'luna@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400', 2, NOW()
FROM auth.users WHERE email = 'luna@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400', 3, NOW()
FROM auth.users WHERE email = 'luna@demo.com'
ON CONFLICT DO NOTHING;

-- Chris's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400', 1, NOW()
FROM auth.users WHERE email = 'chris@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1519085360753-af0119f5cbe7?w=400', 2, NOW()
FROM auth.users WHERE email = 'chris@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400', 3, NOW()
FROM auth.users WHERE email = 'chris@demo.com'
ON CONFLICT DO NOTHING;

-- Jordan's photos
INSERT INTO public.profile_photos (user_id, url, sort_order, created_at)
SELECT id, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400', 1, NOW()
FROM auth.users WHERE email = 'jordan@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400', 2, NOW()
FROM auth.users WHERE email = 'jordan@demo.com'
UNION ALL
SELECT id, 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400', 3, NOW()
FROM auth.users WHERE email = 'jordan@demo.com'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- PART 3: ASSIGN LENSES TO DEMO USERS
-- ============================================================================

-- EMMA: Calm & Cozy + Creative & Curious + Healthy & Grounded
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'emma@demo.com' AND l.key = 'calm_cozy'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'emma@demo.com' AND l.key = 'creative_curious'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'emma@demo.com' AND l.key = 'healthy_grounded'
ON CONFLICT DO NOTHING;

-- JAKE: Active & Energetic + Ambitious & Driven + Healthy & Grounded
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'jake@demo.com' AND l.key = 'active_energetic'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'jake@demo.com' AND l.key = 'ambitious_driven'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'jake@demo.com' AND l.key = 'healthy_grounded'
ON CONFLICT DO NOTHING;

-- SARAH: Values & Roots + Healthy & Grounded + Calm & Cozy
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'sarah@demo.com' AND l.key = 'values_roots'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'sarah@demo.com' AND l.key = 'healthy_grounded'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'sarah@demo.com' AND l.key = 'calm_cozy'
ON CONFLICT DO NOTHING;

-- MIA: Creative & Curious + Humorous & Playful + Social & Spontaneous
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'mia@demo.com' AND l.key = 'creative_curious'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'mia@demo.com' AND l.key = 'humorous_playful'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'mia@demo.com' AND l.key = 'social_spontaneous'
ON CONFLICT DO NOTHING;

-- ALEX: Social & Spontaneous + Active & Energetic + Humorous & Playful
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'alex@demo.com' AND l.key = 'social_spontaneous'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'alex@demo.com' AND l.key = 'active_energetic'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'alex@demo.com' AND l.key = 'humorous_playful'
ON CONFLICT DO NOTHING;

-- OLIVIA: Healthy & Grounded + Calm & Cozy + Values & Roots
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'olivia@demo.com' AND l.key = 'healthy_grounded'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'olivia@demo.com' AND l.key = 'calm_cozy'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'olivia@demo.com' AND l.key = 'values_roots'
ON CONFLICT DO NOTHING;

-- DAVID: Ambitious & Driven + Active & Energetic + Values & Roots
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'david@demo.com' AND l.key = 'ambitious_driven'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'david@demo.com' AND l.key = 'active_energetic'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'david@demo.com' AND l.key = 'values_roots'
ON CONFLICT DO NOTHING;

-- LUNA: Humorous & Playful + Social & Spontaneous + Creative & Curious
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'luna@demo.com' AND l.key = 'humorous_playful'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'luna@demo.com' AND l.key = 'social_spontaneous'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'luna@demo.com' AND l.key = 'creative_curious'
ON CONFLICT DO NOTHING;

-- CHRIS: Balanced mix - Active & Energetic + Creative & Curious + Calm & Cozy
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'chris@demo.com' AND l.key = 'active_energetic'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'chris@demo.com' AND l.key = 'creative_curious'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'chris@demo.com' AND l.key = 'calm_cozy'
ON CONFLICT DO NOTHING;

-- JORDAN: Creative + Active mix - Creative & Curious + Active & Energetic + Healthy & Grounded
INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 1
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'jordan@demo.com' AND l.key = 'creative_curious'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 2
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'jordan@demo.com' AND l.key = 'active_energetic'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_lenses (user_id, lens_id, rank)
SELECT u.id, l.id, 3
FROM auth.users u
CROSS JOIN public.lenses l
WHERE u.email = 'jordan@demo.com' AND l.key = 'healthy_grounded'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- VERIFICATION QUERIES (Commented out to prevent migration failure)
-- ============================================================================

-- View all demo users with their assigned lenses
-- SELECT
--   p.name,
--   p.age,
--   p.city,
--   l1.name AS lens_1,
--   l2.name AS lens_2,
--   l3.name AS lens_3
-- FROM public.profiles p
-- LEFT JOIN public.user_lenses ul1 ON p.user_id = ul1.user_id AND ul1.rank = 1
-- LEFT JOIN public.lenses l1 ON ul1.lens_id = l1.id
-- LEFT JOIN public.user_lenses ul2 ON p.user_id = ul2.user_id AND ul2.rank = 2
-- LEFT JOIN public.lenses l2 ON ul2.lens_id = l2.id
-- LEFT JOIN public.user_lenses ul3 ON p.user_id = ul3.user_id AND ul3.rank = 3
-- LEFT JOIN public.lenses l3 ON ul3.lens_id = l3.id
-- ORDER BY p.name;

-- Count demo users with photos
-- SELECT
--   p.name,
--   (SELECT COUNT(*) FROM public.profile_photos WHERE user_id = p.user_id) as photo_count
-- FROM public.profiles p
-- ORDER BY p.name;

