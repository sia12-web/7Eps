# Automatic Lens Detection System - Complete Guide

## Overview
Instead of asking users to manually pick 3 lenses, the system **automatically detects their vibe** based on their profile data and assigns the best matching lenses.

---

## How It Works

### 1. User Completes Profile
User provides:
- **5-12 interests** (e.g., "Reading", "Gym", "Meditation", "Yoga", "Coffee")
- **Optional bio** (e.g., "I'm a software engineer who loves hiking and meditation")
- **Optional job/field of study** (e.g., "Art Student", "Nursing")

### 2. System Analyzes Profile
The `detect_user_lenses()` function:

**Scores each lens based on:**
- ✅ **Interest matches** (weighted by relevance)
- ✅ **Bio keyword detection** (bonus points)
- ✅ **Job/field clues** (bonus points)

**Example:**
```
User interests: ["Reading", "Meditation", "Yoga", "Coffee", "Writing"]
User bio: "I'm a writer who loves quiet mornings and cozy cafes"

Calm & Cozy lens score:
  Reading (+2) + Meditation (+2) + Yoga (+1.8) + Coffee (+2) + Writing (+2)
  + Bio bonus: "quiet", "cafes" (+2)
  = 11.8 points ✓

Active & Energetic lens score:
  Yoga (+1.8) = 1.8 points (below threshold)

Result: User is assigned "Calm & Cozy" lens!
```

### 3. Auto-Assigns Top 3 Lenses
- System picks the 3 lenses with highest scores (≥4 points each)
- Automatically saves to `user_lenses` table
- Shows user: **"We detected your vibe and set 3 lenses for you!"**

### 4. User Can Still Override
- If system detects wrong lenses, user can manually edit via Lens Picker
- Full transparency: Shows which lenses were auto-detected and their scores

---

## Lens Detection Rules

| Lens | Key Signals (High Weight) | Bonus Keywords | Min Score |
|------|---------------------------|---------------|-----------|
| **Calm & Cozy** | Reading, Coffee, Meditation, Yoga, Books, Mindfulness | quiet, peaceful, introvert, cozy | 4.0 |
| **Active & Energetic** | Gym, Running, Hiking, Sports, Fitness, Adventure | energetic, active, workout, gym | 4.0 |
| **Values & Roots** | Religion, Family, Volunteering, Faith, Tradition | faith, family, traditional, values | 4.0 |
| **Creative & Curious** | Art, Music, Photography, Design, Museums, Creativity | creative, artistic, curious, imagine | 4.0 |
| **Social & Spontaneous** | Parties, Concerts, Festivals, Events, Networking | extrovert, social, outgoing, parties | 4.0 |
| **Healthy & Grounded** | Yoga, Meditation, Wellness, Nature, Health | mindful, balanced, healthy, grounded | 4.0 |
| **Ambitious & Driven** | Technology, Business, Career, Entrepreneurship | ambitious, driven, career, goals | 4.0 |
| **Humorous & Playful** | Comedy, Gaming, Movies, Netflix, Fun, Humor | funny, humor, playful, lighthearted | 4.0 |

---

## Real Examples

### Example 1: Software Engineer
**Profile:**
- Job: Software Engineer
- Interests: Technology, Hiking, Meditation, Yoga, Coffee, Running
- Bio: "Love exploring trails and finding inner peace through yoga"

**Detected Lenses:**
1. **Active & Energetic** (Hiking +2.3, Running +2, Yoga +1.8) = 6.1
2. **Calm & Cozy** (Meditation +2, Yoga +1.8, Coffee +2) = 5.8
3. **Ambitious & Driven** (Technology +2.3) = 2.3

### Example 2: Art Student
**Profile:**
- Field: Fine Arts
- Interests: Art, Music, Parties, Concerts, Photography, Fashion
- Bio: "Always creating and love meeting new people at gallery openings"

**Detected Lenses:**
1. **Creative & Curious** (Art +2.5, Music +2.5, Photography +2.3, Fashion +1.8) = 9.1
2. **Social & Spontaneous** (Parties +2.5, Concerts +2.3) = 4.8
3. **Humorous & Playful** (Music +2.5) = 2.5

### Example 3: Nursing Student
**Profile:**
- Field: Nursing
- Interests: Family, Religion, Volunteering, Health, Cooking, Nature
- Bio: "Family-oriented and love helping others live healthier lives"

**Detected Lenses:**
1. **Values & Roots** (Family +2.5, Religion +2.5, Volunteering +2) = 7.0
2. **Healthy & Grounded** (Health +2, Nature +2, Cooking +1.8) = 5.8
3. **Calm & Cozy** (Cooking +1.5, Nature +2) = 3.5 (below threshold!)

---

## Technical Implementation

### Database Functions (Migration 016)

**1. `detect_user_lenses(user_id)`**
- Analyzes user's interests, bio, job
- Scores each lens based on matching signals
- Returns top 3 lenses with confidence scores

**2. `auto_assign_user_lenses(user_id)`**
- Automatically assigns top 3 lenses to user
- Returns success message with lens count
- Called automatically after profile completion

**3. Trigger `trigger_auto_detect_lenses`**
- Fires when user updates interests (5+ interests)
- Calls `auto_assign_user_lenses()` in background
- No manual intervention needed

### Flutter Integration

**Call after profile completion:**
```dart
final response = await supabase.client.rpc('auto_assign_user_lenses',
  params: {'p_user_id': userId});

// Show message to user
if (response['lenses_assigned'] == 3) {
  showSnackBar("We detected your vibe and set 3 lenses for you!");
}
```

---

## User Experience

### Before (Manual Selection)
1. Complete profile
2. See nudge: "Pick 3 lenses"
3. Open Lens Picker
4. Read 8 lens descriptions
5. Select 3 lenses
6. Save

### After (Automatic Detection)
1. Complete profile
2. System auto-detects lenses in background ✨
3. Shows: "We detected your vibe and set 3 lenses for you!"
4. See lens chips in header
5. Can still edit manually if desired

---

## Benefits

✅ **Zero effort required** - System figures it out automatically
✅ **More accurate** - Based on actual behavior/data, not self-perception
✅ **Better UX** - No need to understand "lenses" concept
✅ **Transparent** - Can still override if wrong
✅ **Adaptable** - Updates as user changes profile

---

## How to Apply

1. **Open:** https://supabase.com/dashboard/project/7eps/sql
2. **Run migration 016:** `014_create_demo_users_fixed.sql`
3. **Run migration 016:** `016_auto_lens_detection.sql`
4. **Run migration 015:** `015_assign_lenses_to_demo_users.sql`

Now when users complete their profile with 5+ interests, lenses are automatically detected! 🎯
