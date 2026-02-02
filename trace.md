# 7Eps - Project Trace

## Project Overview

**App Name:** 7Eps (pronounced "Seven Eps")
**Description:** Progressive Disclosure Dating App
**Tech Stack:** Flutter Web + Supabase
**Date Started:** 2026-01-31

## Core Product Concept

A dating app with progressive disclosure through 7 episodes:
- **Daily Edition:** 3-5 curated matches per day (no infinite feed)
- **Max 3 Active Journeys:** Scarcity model
- **Progressive Photo Unblur:**
  - Episode 1: 25% unblur
  - Episode 2: 50% unblur + bio/interests
  - Episode 3: 75% unblur + compatibility score
  - Episode 4: 100% unblur
- **Episodes 1-7:** Must complete in order (guided journey)
- **Book Timeline:** "Artifacts" pinned to timeline (not chat bubbles)

## Supabase Configuration

**Project URL:** https://mmvuzxtrweshvvyhmarv.supabase.co
**Project ID:** mmvuzxtrweshvvyhmarv

**Credentials Location:** Hard-coded in `lib/core/supabase/supabase_client.dart` (Flutter Web compatibility - dotenv doesn't work on web)

## Database Schema

### Tables Applied (via migrations)

1. **profiles** - User profiles with onboarding tracking
2. **profile_photos** - User photos (max 3)
3. **matches** - Match/journey records
4. **match_participants** - Many-to-many relationship
5. **artifacts** - Episode submissions
6. **daily_editions** - Daily candidate matches

### Onboarding Fields (Migration 009)

**Added to profiles table:**
- `onboarding_step` (INT) - Tracks progress (1-11)
- `dob` (DATE) - Date of birth for age verification
- `pronouns` (TEXT) - User's preferred pronouns
- `headline` (TEXT) - Profile tagline (max 100 chars)
- `gender_interest` (TEXT) - Dating preference (men/women/everyone)
- `age_min` (INT) - Minimum age preference (18-100)
- `age_max` (INT) - Maximum age preference (18-100)
- `distance_radius` (INT) - Distance preference (10-200km)
- `terms_accepted_at` (TIMESTAMPTZ) - Terms acceptance timestamp
- `safety_agreement_accepted_at` (TIMESTAMPTZ) - Safety agreement timestamp
- `onboarding_completed_at` (TIMESTAMPTZ) - Onboarding completion timestamp

### Important Database Decisions

- **UUID Generation:** Uses `gen_random_uuid()` (PostgreSQL built-in) instead of `uuid_generate_v4()` due to compatibility
- **RLS Policies:** Defined in migrations (002_rls_policies.sql)
- **Row Level Security:** Users can read all profiles, only update their own

## Architecture Decisions

### ❌ REJECTED Approaches

1. **Code Generation (freezed/riverpod_generator)**
   - **Problem:** Dependency conflicts with `analyzer_plugin 0.12.0` vs `analyzer 7.6.0`
   - **Solution:** Removed all code generation, using simple Dart classes with manual JSON serialization

2. **flutter_dotenv for environment variables**
   - **Problem:** Doesn't work on Flutter Web (fetch errors for .env file)
   - **Solution:** Hard-coded Supabase credentials directly in supabase_client.dart

3. **uuid_generate_v4()**
   - **Problem:** Function doesn't exist in Supabase PostgreSQL
   - **Solution:** Changed to `gen_random_uuid()` (built-in)

### ✅ ACCEPTED Approaches

1. **State Management:** Riverpod (without code generation)
2. **Navigation:** go_router
3. **Data Models:** Simple Dart classes with `fromJson()`/`toJson()`
4. **Authentication:** Supabase Auth (email/password)
5. **Storage:** Supabase Storage for profile photos

## Package Name

**Current:** `sevent_eps`
**Changed from:** `love_journey` (user correction)

## Files Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root app widget (SevenEpsApp)
├── core/
│   ├── router/router.dart       # go_router configuration
│   ├── supabase/
│   │   └── supabase_client.dart # Supabase init with credentials
│   └── theme/app_theme.dart     # Colors, typography
├── models/
│   ├── profile.dart             # Profile data model with onboarding fields
│   ├── profile_photo.dart       # Photo model
│   ├── match.dart               # Match/journey model
│   ├── artifact.dart            # Episode submission model
│   ├── episode.dart             # Episode definitions
│   ├── interests.dart           # 60+ predefined interests
│   └── onboarding_data.dart     # Onboarding progress tracking model
├── providers/
│   ├── auth_provider.dart       # Authentication state + error handling
│   ├── profile_provider.dart    # Profile CRUD operations + photo upload
│   └── onboarding_provider.dart # Onboarding state management
├── features/
│   ├── auth/
│   │   ├── auth_screen.dart     # Landing page (Sign In / Register)
│   │   ├── login_screen.dart    # Login form with helpful error hints
│   │   └── register_screen.dart # Registration form
│   ├── onboarding/
│   │   ├── onboarding_flow_screen.dart  # Multi-step flow container
│   │   └── steps/
│   │       ├── welcome_slides_step.dart     # Steps 1-3: Intro slides
│   │       ├── age_gate_step.dart          # Step 4: Age verification (18+)
│   │       ├── basics_step.dart            # Step 5: Name, city, pronouns
│   │       ├── interests_step.dart         # Step 6: Interest selection (5-12)
│   │       ├── photos_step.dart            # Step 7: Photo upload (1-3) with blur preview
│   │       ├── preferences_step.dart       # Step 8: Gender, age, distance
│   │       ├── safety_step.dart            # Step 9: Safety agreement
│   │       ├── tutorial_step.dart          # Step 10: Episode system tutorial
│   │       └── generate_daily_edition_step.dart # Step 11: Generate matches
│   ├── profile/
│   │   ├── edit_profile_screen.dart   # Profile creation/editing (deprecated)
│   │   ├── photo_upload_widget.dart   # Photo upload UI (extracted)
│   │   └── interests_selector.dart    # Interest selection (extracted)
│   └── home/
│       └── home_screen.dart     # Placeholder home (Phase 3 coming)
└── utils/
    └── (to be added)
```

## Completed Features

### ✅ Phase 1: Foundation + Auth (COMPLETE)

**Authentication Flow:**
- Email/password registration
- Email verification required
- Login with error handling
- User-friendly error messages with helpful hints
- Router redirect based on auth state

**Error Handling:**
- Technical Supabase errors parsed to user-friendly messages
- Helpful hints based on error type (e.g., "Check for typos", "Verify your email")

**Files Created/Modified:**
- `lib/providers/auth_provider.dart` - Auth state + `_getErrorMessage()` method
- `lib/features/auth/auth_screen.dart` - Landing page
- `lib/features/auth/login_screen.dart` - Login + `_buildHelpfulHint()`
- `lib/features/auth/register_screen.dart` - Registration + `_buildHelpfulHint()`
- `lib/core/supabase/supabase_client.dart` - Supabase initialization

### ✅ Phase 2: Multi-Step Onboarding Flow (COMPLETE)

**11-Step Guided Onboarding:**
1. **Welcome Slides (Steps 1-3):** Introduction to 7Eps concept
   - "3-5 Quality Matches Daily"
   - "7 Episodes → Real Date"
   - "3 Active Journeys Max"

2. **Age Gate (Step 4):** Mandatory age verification
   - DOB picker (Month, Day, Year dropdowns)
   - Hard block if under 18 (sign-out + redirect to auth)
   - Checkbox confirmation: "I confirm I am 18+"

3. **Basics (Step 5):** Core profile information
   - First name (required, 2-50 chars)
   - Pronouns (dropdown: He/Him, She/Her, They/Them, Custom)
   - City (required, 2-100 chars)
   - University/Campus (optional)
   - Headline removed (user feedback)

4. **Interests (Step 6):** Interest selection
   - Select 5-12 interests from curated list
   - Counter display: "X/12 selected"
   - Extracted from existing `interests_selector.dart`

5. **Photos (Step 7):** Photo upload with blur preview
   - Min 1 photo, max 3 photos
   - **Flutter Web compatible** (uses `Image.network()` for web, `Image.file()` for mobile)
   - **Blur preview** showing Episode 1 appearance (sigma=10 blur)
   - Grid layout showing all uploaded photos with number badges
   - Clear explanation: "Your photos will be blurred at Episode 1 and gradually become clearer"

6. **Preferences (Step 8):** Dating preferences
   - Gender interest: Men | Women | Everyone (segmented control)
   - Age range: **Text input fields** for precise control (18-100)
     - Default max age = user's age + 10 (calculated from DOB)
     - Auto-adjustment: if min > max, max updates to match min
     - Validation: must be between 18-100
   - Distance radius: **Continuous slider** (1km precision) + **text input field** (10-200km)
     - Slider and text field stay synchronized
     - User can type exact value or use slider for visual feedback

7. **Safety Agreement (Step 9):** Community guidelines
   - Code of conduct (4 sections: Be Respectful, Be Authentic, Stay Safe, Report Issues)
   - Checkbox: "I have read and agree to the Community Guidelines"
   - Stores timestamp in `safety_agreement_accepted_at`

8. **Tutorial (Step 10):** Episode system explanation
   - Visual timeline showing 7 episode cards
   - Artifact examples with icons
   - "Both must complete episode to unlock next" explanation

9. **Generate Daily Edition (Step 11):** Match generation
   - Loading animation: "Finding your first matches..."
   - Calls daily edition generation function
   - Sets `onboarding_completed_at = NOW()`
   - Auto-redirects to `/daily-edition` after completion

**Progress Tracking:**
- `onboarding_step` field stores current step (1-11)
- Resumable progress (can quit and return later)
- Auto-save on each step completion
- Progress indicator bar on every screen (except welcome slides)

**Navigation Architecture:**
- URL-based routing: `/onboarding/:step`
- `_currentStep` changed from state variable to getter (fixes navigation loop bug)
- **Welcome slides navigation fix:** Step 1 only shows WelcomeSlidesStep, navigates directly to step 4 when complete
- Steps 2 and 3 auto-advance to step 4 if accessed directly (prevents rebuild loops)
- Back button (disabled on step 1)
- Forward button validation-dependent

**Data Models:**
- `OnboardingData` model with `currentStep` and `formData` map
- `Profile` model extended with 11 onboarding fields
- Auto-save to database on each step

**Router Logic:**
- Authenticated users → `/onboarding/1` (or saved step)
- Onboarding step loaded from `onboarding_step` field
- Protected routes (`/daily-edition`, `/journeys`) blocked until step 11 complete

**Validation Rules Summary:**
| Step | Required | Validation |
|------|----------|------------|
| 1-3 (Welcome) | None | Always valid |
| 4 (Age Gate) | DOB + checkbox | Age >= 18 AND checkbox checked |
| 5 (Basics) | Name + City | Name >= 2 chars, City >= 2 chars |
| 6 (Interests) | Interests | 5-12 interests selected |
| 7 (Photos) | Photos | At least 1 photo |
| 8 (Preferences) | None | Has default (everyone) |
| 9 (Safety) | Checkbox | Must be checked |
| 10 (Tutorial) | None | Always valid |
| 11 (Generate) | None | Backend validates |

**Files Created:**
- `supabase/migrations/009_onboarding_fields.sql` - Database schema for onboarding
- `lib/models/onboarding_data.dart` - Onboarding progress model
- `lib/providers/onboarding_provider.dart` - Onboarding state management
- `lib/features/onboarding/onboarding_flow_screen.dart` - Flow container
- `lib/features/onboarding/steps/welcome_slides_step.dart` - Steps 1-3
- `lib/features/onboarding/steps/age_gate_step.dart` - Step 4
- `lib/features/onboarding/steps/basics_step.dart` - Step 5
- `lib/features/onboarding/steps/interests_step.dart` - Step 6
- `lib/features/onboarding/steps/photos_step.dart` - Step 7 (with web compatibility)
- `lib/features/onboarding/steps/preferences_step.dart` - Step 8
- `lib/features/onboarding/steps/safety_step.dart` - Step 9
- `lib/features/onboarding/steps/tutorial_step.dart` - Step 10
- `lib/features/onboarding/steps/generate_daily_edition_step.dart` - Step 11

**Bug Fixes:**
- ✅ Fixed 3-click navigation bug on welcome slides
  - Changed to show WelcomeSlidesStep only on step 1
  - Navigates directly to step 4 when complete, skipping steps 2-3
  - Steps 2 and 3 auto-advance to step 4 if accessed directly
- ✅ Fixed Flutter Web photo upload crash
  - Added `kIsWeb` check to use `Image.network()` instead of `Image.file()`
- ✅ Removed redundant Auth step (users already authenticated)
- ✅ Removed skip button from welcome slides (onboarding should not be skippable)
- ✅ Removed headline field from Basics step (user feedback)
- ✅ Added clear explanation about photo blur progression
- ✅ Changed to grid layout showing all uploaded photos instead of just first one
- ✅ Improved age and distance controls with precise input
  - Replaced dropdown with text input fields for exact age values
  - Added continuous slider (1km precision) + text input for distance
  - Calculate default max age as user's age + 10 based on DOB

## Database Migrations Applied

1. **001_initial_schema.sql** - Core tables (profiles, profile_photos, matches, etc.)
2. **002_rls_policies.sql** - Row Level Security policies
3. **003_functions_triggers.sql** - Postgres functions and triggers
4. **004_match_functions.sql** - Additional match-related functions
5. **009_onboarding_fields.sql** - Onboarding tracking fields (11 new columns)

**Command to apply:** `supabase db push`

## UI/UX Theme

**Aesthetic:** "Indie bookstore meets high-end journal"

**Color Palette:**
- Sage Green: #87A878
- Terracotta: #C17F59
- Cream: #F5F1E8
- Charcoal: #3D3D3D

**Typography:**
- Headings: Serif font (Merriweather or similar)
- Body: Clean sans (Inter or SF Pro)

## Current Router Routes

```dart
/auth                - Auth landing screen
/login               - Login screen
/register            - Registration screen
/onboarding          - Redirects to /onboarding/1 (or saved step)
/onboarding/:step    - Multi-step onboarding flow (steps 1-11)
/daily-edition       - Daily matches (protected, requires onboarding complete)
/journeys            - Active journeys (protected, requires onboarding complete)
/                    - Home screen (placeholder)
/profile/edit        - Edit profile (not currently used)
```

## Known Issues & Workarounds

1. **Image Picker on Web:** ✅ Fixed - Now uses `Image.network()` for web, `Image.file()` for mobile
2. **Hot Reload:** Some changes require full restart (especially pubspec.yaml changes)
3. **Flutter Web:** Some packages don't support web platform
4. **Navigation State Desync:** ✅ Fixed - Changed to URL-based state management

## Development Commands

```bash
# Start development server
flutter run -d chrome

# Hot reload (in Flutter terminal)
r

# Hot restart (in Flutter terminal)
R

# Apply database migrations
supabase db push

# Run tests
flutter test
```

## Next Steps (Future Phases)

### Phase 3: Daily Edition (NOT STARTED)
- Daily candidate generation algorithm (3-5 matches)
- Daily Edition shelf UI
- Start Journey flow (with max 3 enforcement)
- Candidate filtering (same city/university)

### Phase 4: Episode Engine (NOT STARTED)
- Episode progression UI (1-7)
- Artifact submission forms
- Episode validation (server-side)
- Progressive unblur animation
- Episode rewards

### Phase 5: Book Timeline (NOT STARTED)
- Timeline of artifacts (not chat bubbles)
- Supabase Realtime subscriptions
- Artifact cards (milestone style)

### Phase 6: Polish + Testing (NOT STARTED)
- Full flow testing
- Performance optimization
- Error handling
- Loading states

## Important Code Patterns

### Provider Pattern (Without Code Generation)

```dart
final authProvider = StateNotifierProvider<Auth, bool>((ref) {
  return Auth();
});

// Usage
final authState = ref.watch(authProvider);
```

### Model Serialization

```dart
class Profile {
  final String userId;
  final String name;
  // ...

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['user_id'],
      name: json['name'],
      // ...
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      // ...
    };
  }
}
```

### Error Handling Pattern

```dart
String _getErrorMessage(dynamic error) {
  final errorString = error.toString();

  if (errorString.contains('Invalid login credentials')) {
    return 'Invalid email or password. Please try again.';
  }
  // ... more cases

  return 'Something went wrong. Please try again.';
}
```

## User Feedback & Corrections

1. **App Name:** User corrected that app is called "7Eps" not "Love Journey" - Updated all branding
2. **Onboarding Issue:** User reported login went straight to main page instead of onboarding - Fixed with profile completion check
3. **Error Messages:** User requested better error prompts - Implemented user-friendly error messages with helpful hints
4. **Redundant Auth Step:** User pointed out auth appears at beginning AND after onboarding, which is confusing - Removed auth step from onboarding flow (users already authenticated)
5. **Skip Button Confusion:** User questioned why onboarding has a skip button - Removed skip button (onboarding should not be skippable)
6. **Photo Upload Confusion:** User unclear if photos are for Episode 1 or all episodes, and couldn't see all 3 photos - Added clear explanation and changed to grid layout showing all photos with blur preview
7. **Double-Click Bug:** User reported "Get Started" button required two clicks to work - Fixed by changing `_currentStep` from state variable to getter reading URL parameter
8. **3-Click Navigation Bug:** User reported having to click "Get Started" 3 times to advance from welcome slides - Fixed by making step 1 navigate directly to step 4, skipping intermediate steps 2-3 to prevent rebuild loops
9. **Max Age Range:** User reported max age of 100 seemed weird - Changed default max age to user's age + 10 (calculated from DOB), capped at 100
10. **Precise Control Request:** User wanted better control over age and distance selection - Replaced dropdown with text input fields for exact age values (18-100), added continuous slider (1km precision) + text input for distance (10-200km)

## Testing Status

- ✅ Registration tested successfully
- ✅ Login tested successfully
- ✅ 11-step onboarding flow tested
- ✅ Age gate (18+ verification) tested
- ✅ Photo upload with blur preview tested (Flutter Web compatible)
- ✅ Navigation between onboarding steps tested
- ✅ Progress tracking and resumable onboarding tested
- ✅ Welcome slides navigation tested (single-click advance to step 4)
- ✅ Precise age and distance controls tested
- ✅ Headline field removal tested
- ❌ Daily Edition generation implemented but returns 0 candidates (no other users)
- ❌ Episode system not yet implemented

## Git Status

**Repository:** Active git repository
**Total Commits:** 3
- `8384b07` - Implement comprehensive 12-step onboarding flow for 7Eps dating app
- `4235033` - Fix onboarding navigation and UX issues
- `c326510` - Fix onboarding UX issues and improve controls
  - Fix welcome slides navigation loop (3-click bug)
  - Remove headline field from Basics step
  - Improve age and distance controls with precise input
  - Add validation for age (18-100) and distance (10-200km) ranges

---

**Last Updated:** 2026-02-02
**Current Phase:** Phase 2 (Multi-Step Onboarding Flow) - COMPLETE
**Next Phase:** Phase 3 (Daily Edition Generation)
