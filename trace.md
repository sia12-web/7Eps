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

1. **profiles** - User profiles
2. **profile_photos** - User photos (max 3)
3. **matches** - Match/journey records
4. **match_participants** - Many-to-many relationship
5. **artifacts** - Episode submissions
6. **daily_editions** - Daily candidate matches

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
│   ├── profile.dart             # Profile data model
│   ├── profile_photo.dart       # Photo model
│   ├── match.dart               # Match/journey model
│   ├── artifact.dart            # Episode submission model
│   ├── episode.dart             # Episode definitions
│   └── interests.dart           # 60+ predefined interests
├── providers/
│   ├── auth_provider.dart       # Authentication state + error handling
│   └── profile_provider.dart    # Profile CRUD operations
├── features/
│   ├── auth/
│   │   ├── auth_screen.dart     # Landing page (Sign In / Register)
│   │   ├── login_screen.dart    # Login form with helpful error hints
│   │   └── register_screen.dart # Registration form
│   ├── profile/
│   │   ├── onboarding_screen.dart     # Wraps EditProfileScreen
│   │   ├── edit_profile_screen.dart   # Profile creation/editing
│   │   ├── photo_upload_widget.dart   # Photo upload UI
│   │   └── interests_selector.dart    # Interest selection
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

### ✅ Phase 2: Profile + Onboarding (COMPLETE)

**Profile Features:**
- Multi-step profile creation form
- Photo upload (up to 3 photos)
- Interest selection (max 10 interests, 60+ options across 6 categories)
- Profile completion percentage tracker
- Onboarding flow that checks if profile is complete
- Redirects to home if profile already complete

**Data Models:**
- `Profile` model with `isComplete` and `completionPercentage` getters
- `ProfilePhoto` model for photo management
- `Interests` data with 60+ interests categorized

**Router Logic:**
- Authenticated users → `/onboarding`
- `/onboarding` checks if profile is complete
  - If complete → redirect to `/` (home)
  - If not complete → show profile creation form
- After saving profile → redirect to `/` (home)

**Files Created:**
- `lib/models/profile.dart` - Profile model with completion tracking
- `lib/models/profile_photo.dart` - Photo model
- `lib/models/interests.dart` - 60+ interests data
- `lib/providers/profile_provider.dart` - Profile CRUD + photo upload
- `lib/features/profile/onboarding_screen.dart` - Onboarding wrapper
- `lib/features/profile/edit_profile_screen.dart` - Profile form
- `lib/features/profile/photo_upload_widget.dart` - Photo upload UI
- `lib/features/profile/interests_selector.dart` - Interest selection
- `lib/features/home/home_screen.dart` - Placeholder home screen

## Database Migrations Applied

1. **001_initial_schema.sql** - Core tables (profiles, profile_photos, matches, etc.)
2. **002_rls_policies.sql** - Row Level Security policies
3. **003_functions_triggers.sql** - Postgres functions and triggers
4. **004_match_functions.sql** - Additional match-related functions

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
/auth          - Auth landing screen
/login         - Login screen
/register      - Registration screen
/onboarding    - Profile onboarding (redirects if complete)
/              - Home screen (placeholder)
/profile/edit  - Edit profile (not currently used)
```

## Known Issues & Workarounds

1. **Image Picker on Web:** May have limitations compared to mobile
2. **Hot Reload:** Some changes require full restart (especially pubspec.yaml changes)
3. **Flutter Web:** Some packages don't support web platform

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

## Testing Status

- ✅ Registration tested successfully
- ✅ Login tested successfully
- ✅ Profile creation flow tested
- ❌ Daily Edition not yet implemented
- ❌ Episode system not yet implemented

## Git Status

**Current:** Not a git repository (no `.git` folder)

---

**Last Updated:** 2026-01-31
**Current Phase:** Phase 2 (Profile + Onboarding) - COMPLETE
**Next Phase:** Phase 3 (Daily Edition)
