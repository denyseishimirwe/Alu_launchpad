# LaunchPad ALU

A Flutter mobile app connecting **ALU students** with **student-led startups** for internships and project roles. Built as a final assignment project for African Leadership University.

## Features

### Students
- Sign up / sign in (email + Google)
- Role-based onboarding (Student vs Founder)
- Home feed with featured match, search, and category filters
- Explore opportunities with saved filter
- Apply to roles with skill-match scoring
- Track applications with tabs: **Applied · In review · Accepted · All**
- Real-time status updates and in-app notifications
- Save/bookmark opportunities
- Edit profile (skills, degree, location)
- Withdraw applications

### Founders
- Create and edit startup profile
- Post internship opportunities
- Review applicants and update status (Applied → Review → Shortlisted → Accepted)
- Close postings
- Dashboard with applicant stats

## Tech stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.12+ |
| Backend | Firebase Auth, Cloud Firestore |
| State | Riverpod |
| Routing | go_router + AuthGate |
| Fonts | Plus Jakarta Sans (google_fonts) |

## Project structure

```
lib/
├── core/           # theme, router, constants, sample data seeder
├── features/
│   ├── auth/       # login, signup, role selection
│   ├── student/    # home, explore, applications, profile
│   └── founder/    # dashboard, applicants, post, profile
└── shared/         # models, widgets, utils
```

## Setup

### Prerequisites
- Flutter SDK 3.12+
- Android Studio / Xcode (for emulators)
- Firebase project: `alu-launchpad-bdc6b`

### Run locally

```bash
git clone https://github.com/denyseishimirwe/Alu_Launchpad.git
cd alu_launchpad
flutter pub get
flutter run
```

### Firebase

1. Enable **Email/Password** and **Google** auth in Firebase Console
2. Create a Firestore database
3. Deploy rules and indexes:

```bash
firebase deploy --only firestore --project alu-launchpad-bdc6b
```

4. Register Android SHA-1 in Firebase for Google Sign-In

## Demo flow (for video)

1. **Student account** — sign up → choose Student → browse Home → apply → check Applications tab
2. **Founder account** — sign up (second device/emulator) → choose Founder → set up startup → post opportunity
3. **Founder** — Applicants tab → update student status to Shortlisted
4. **Student** — see notification + updated progress stepper in real time
5. Show Firebase Console — Auth users + Firestore collections (`users`, `startups`, `opportunities`, `applications`)

## Firestore collections

| Collection | Purpose |
|------------|---------|
| `users` | Profiles, roles, skills, saved opportunities |
| `startups` | Founder organization profiles |
| `opportunities` | Posted roles |
| `applications` | Student applications with status |
| `users/{id}/notifications` | In-app notifications |

## Rubric checklist (55 pts)

| Criteria | Points | Status |
|----------|--------|--------|
| UI/UX — polished, consistent design | 10 | Done |
| Firebase Auth — login, register, session | 4 | Done |
| Firestore CRUD — live data in console | 6 | Done |
| State management & architecture (Riverpod) | 8 | Done |
| Feature implementation (loading, errors, validation) | 7 | Done |
| Technical demo video | 5 | **You record** |
| Code quality — modular structure | 5 | Done |
| Technical report (APA/IEEE) | 5 | **You write** |
| Product thinking — ALU ecosystem fit | 5 | Done |

## Author

Denyse Ishimirwe — ALU Student (`d.ishimrwe@alustudent.com`)
