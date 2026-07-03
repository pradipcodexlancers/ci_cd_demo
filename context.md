# Project Context — ci_cd_demo

This document is a complete, file-by-file map of the project: what it is, what it's built with, how data flows through it, and where to find things. Read this once and you should be able to navigate the whole codebase without guessing.

## 1. What this app is

A Flutter notes app with Firebase-backed email/password auth. A user registers, logs in, and then creates/edits/deletes personal notes that are stored per-account in Firestore in real time. It also has a profile screen and a light/dark theme toggle persisted on-device.

There is currently **no CI/CD pipeline configured** (no `.github/workflows`, no `codemagic.yaml`, etc.) despite the project name — if you're looking for it, it doesn't exist yet.

## 2. Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.4), Material 3 |
| State management / DI / routing | [GetX](https://pub.dev/packages/get) (`get: ^4.7.3`) |
| Auth | Firebase Authentication, email/password (`firebase_auth: ^6.5.4`) |
| Database | Cloud Firestore (`cloud_firestore: ^6.6.0`) |
| Local key-value storage | `get_storage: ^2.1.1` (only used to persist the theme preference) |
| Fonts | `google_fonts: ^8.1.0` (Poppins, applied app-wide) |
| Dates | `intl: ^0.20.3` |
| Backend config | `firebase_core`, `firebase_options.dart` (generated via FlutterFire CLI), `firestore.rules` |

## 3. Architecture pattern (GetX MVC-ish)

Every feature lives under `lib/modules/<feature>/` with three matching subfolders:

```
modules/<feature>/
  bindings/<feature>_binding.dart      // registers the controller with Get.lazyPut
  controllers/<feature>_controller.dart // all state + business logic (GetxController)
  views/<feature>_view.dart             // pure UI (GetView<Controller>), no logic
```

- **View** widgets extend `GetView<XController>` and access their controller via `controller.xyz` — no `context`-based lookups.
- **Controller** classes extend `GetxController`, expose `Rx`/`RxBool`/`RxString`/`Rxn` reactive fields, and views wrap the parts that need to rebuild in `Obx(() => ...)`.
- **Binding** classes wire up `Get.lazyPut<XController>(() => XController())` and are attached to the route in `app_pages.dart`, so the controller is created only when that route is first visited and disposed when popped.
- Cross-cutting singletons (`AuthService`, `FirestoreService`, `StorageService`) are **not** bound per-route — they're registered once in `main.dart` before `runApp()` via `Get.put` / `Get.putAsync`, because they must be ready before the very first screen builds. Any controller reaches them via `Get.find<...>()`.

## 4. Navigation / routing

- `lib/routes/app_routes.dart` — `Routes` class: string constants for every route (`/splash`, `/login`, `/register`, `/home`, `/profile`, `/settings`, `/add-note`, `/edit-note`).
- `lib/routes/app_pages.dart` — `AppPages.pages`: the `GetPage` list mapping each route to its `View` + `Binding`. Passed to `GetMaterialApp(getPages: ...)` in `main.dart`.
- Navigation calls used throughout: `Get.toNamed` (push), `Get.back` (pop, optionally with a `result`), `Get.offAllNamed` (replace entire stack — used after login/logout/splash so Back can't return to a screen that requires auth).
- The Add Note and Edit Note screens share **one** view/controller (`NoteFormView` / `NoteFormController`), registered twice under two route names. The controller tells them apart via `Get.arguments`: `null` → adding, a `NoteModel` → editing (passed from `HomeView`'s `onTap: () => Get.toNamed(Routes.editNote, arguments: note)`).
- Register hands its newly-created email back to Login via `Get.back(result: email)`, and Login (`Get.toNamed<String>(Routes.register)`) pre-fills the email field with it — a small UX convenience so the user doesn't retype it.

## 5. App startup sequence (`lib/main.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()` — required before any platform channel call (GetStorage's file I/O) runs pre-`runApp`.
2. `Firebase.initializeApp(...)` using generated `firebase_options.dart`.
3. Register services in dependency order:
   - `StorageService` (async init — reads GetStorage's file from disk)
   - `FirestoreService` (no async setup)
   - `AuthService` (async init — depends on `FirestoreService` being registered first, since it looks up the user's profile document during startup)
4. Read the persisted dark-mode flag so the correct theme is applied on the very first frame (no flash of the wrong theme).
5. `runApp(MyApp(...))` → `GetMaterialApp` with `initialRoute: Routes.splash`.
6. `SplashView`/`SplashController` waits 2 seconds (so the splash branding is visible), then routes to `/home` if `AuthService.isLoggedIn`, else `/login` — via `Get.offAllNamed` so Splash itself isn't kept on the back stack.

## 6. Auth flow (`AuthService`, `lib/services/auth_service.dart`)

`AuthService extends GetxService` and is the single source of truth for "who is logged in," exposed as `Rxn<UserModel> currentUser` (reactive; `null` = logged out). Every screen that needs the logged-in user's data watches this via `Obx`, rather than reading `FirebaseAuth.instance.currentUser` directly — because Firebase's `User` object only has the email, not the app-specific display name stored in Firestore.

- **`init()`** — called once at app startup. Reads Firebase's persisted session (`authStateChanges().first`), hydrates `currentUser` from Firestore, then keeps listening for future auth-state changes (e.g. token revoked / signed out elsewhere).
- **`register({name, email, password})`** — creates the Firebase Auth account, writes the matching `users/{uid}` Firestore profile, then **signs the user back out immediately** (Firebase auto-signs-in a newly created account, but this app intentionally forces an explicit login afterward). Returns `null` on success or a user-facing message on failure.
- **`login({email, password})`** — signs in, then synchronously loads the Firestore profile into `currentUser` before returning, so Home/Profile have data the instant navigation happens.
- **`logout()`** — just `FirebaseAuth.instance.signOut()`; the `authStateChanges()` listener from `init()` clears `currentUser` reactively.
- **`_messageFor(FirebaseAuthException)`** — maps Firebase's raw error codes (`email-already-in-use`, `weak-password`, `wrong-password`, `network-request-failed`, etc.) to the plain-English strings in `AppStrings`, so the UI never shows a Firebase server-log-style message to the user.

Only accounts created via `register()` can subsequently `login()` — there's no other way into the users table.

## 7. Data model & Firestore structure

```
users/{uid}                    { name, email }
users/{uid}/notes/{noteId}     { title, description, createdAt, updatedAt }
```

Notes are a **subcollection** of each user's own document (not a flat top-level `notes` collection filtered by a `uid` field). Two reasons (documented in `firestore_service.dart`): security rules collapse to one `request.auth.uid == uid` check per collection, and reading "this user's notes" needs no `where` filter or composite index.

- `lib/models/user_model.dart` — `UserModel(uid, email, name)`. `uid` is the document id, never duplicated as a field.
- `lib/models/note_model.dart` — `NoteModel(id, title, description, createdAt, updatedAt)`. `createdAt`/`updatedAt` are written server-side via `FieldValue.serverTimestamp()` so ordering never depends on client clocks; `fromSnapshot` falls back to `DateTime.now()` for the split-second right after a local write where the server timestamp hasn't confirmed yet.
- `firestore.rules` — every document under `users/{uid}` (profile + its notes subcollection) is readable/writable only by that signed-in uid. Account deletion isn't exposed in the app, so profile `delete` is hard-denied.

## 8. Services (`lib/services/`)

| File | Responsibility |
|---|---|
| `auth_service.dart` | Everything in §6 above. |
| `firestore_service.dart` | Every Firestore read/write: `createUserProfile`, `fetchUserProfile`, `streamNotes` (real-time `Stream<List<NoteModel>>`, ordered `updatedAt` descending), `addNote`, `updateNote`, `deleteNote`. This is the *only* class that talks to `cloud_firestore` directly. |
| `storage_service.dart` | Thin wrapper around `GetStorage`. Only stores the dark-mode preference (`keyIsDarkMode`) — auth session and notes live in Firebase now, not here. |

## 9. Feature modules (`lib/modules/`)

### `splash/`
Shows branding for 2s, then routes to Home or Login depending on `AuthService.isLoggedIn`. No UI logic beyond that.

### `login/`
- `login_controller.dart` — form validation (`formKey`), `emailController`/`passwordController`, `isLoading`, `isPasswordVisible`. `login()` calls `AuthService.login`; on success shows a success snackbar and `Get.offAllNamed(Routes.home)`; on failure shows the returned error message.
- `login_view.dart` — email + password `CustomTextField`s, `CustomButton` wired to `controller.login`, and a link to Register that awaits its result (`Get.toNamed<String>`) to pre-fill the email field.

### `register/`
- `register_controller.dart` — same shape as Login plus `nameController`/`confirmPasswordController` and two visibility toggles. `register()` calls `AuthService.register`; on success it pops back to Login (handing the email back as the pop `result`) and *then* shows the success snackbar; any unexpected (non-`FirebaseAuthException`) error is now also caught and surfaced instead of silently disappearing.
- `register_view.dart` — name/email/password/confirm-password fields + submit button + "already have an account" link (`Get.back()`).

### `home/`
- `home_controller.dart` — subscribes to `FirestoreService.streamNotes(uid)` on `onInit`, keeping a raw `RxList<NoteModel> _notes`. Exposes:
  - `isLoading`, `errorMessage` (stream lifecycle state)
  - `searchQuery` + `sortOption` (`NoteSortOption`: newest / oldest / titleAz) — both applied **client-side** over the already-fetched notes via the `filteredNotes` getter, so changing search/sort never re-subscribes to Firestore or re-downloads data.
  - `hasAnyNotes` — lets the view distinguish "no notes at all" from "no results for this search."
  - `deleteNote(note)` — shows a confirm dialog first (`showConfirmDialog`), then deletes and snackbars.
  - `retry()` — cancels and restarts the Firestore subscription (used by the error state's Retry button).
- `home_view.dart` — app bar with sort menu (`PopupMenuButton<NoteSortOption>`) + profile/settings icon buttons, a search `TextField`, and a body that switches between loading spinner / error `StatePlaceholder` / empty `StatePlaceholder` / `ListView.builder` of `NoteCard`s based on controller state. FAB pushes `Routes.addNote`; tapping a card pushes `Routes.editNote` with that note as `Get.arguments`.

### `note_form/`
Shared by both Add Note and Edit Note (see §4).
- `note_form_controller.dart` — reads `Get.arguments as NoteModel?` in `onInit` to decide `isEditing`; seeds `titleController`/`descriptionController` accordingly. `save()` validates, then calls `FirestoreService.updateNote` or `.addNote`, pops back to Home first, and *then* shows the success snackbar (see §11 for why the order matters) — Home's Firestore stream already picks up the change in real time, so no manual refresh is needed after the pop.
- `note_form_view.dart` — title + multi-line description `CustomTextField`s + save `CustomButton`. App bar title switches between "Add Note"/"Edit Note" based on `controller.isEditing`.

### `profile/`
- `profile_controller.dart` — exposes `AuthService.currentUser` directly as `user`; `logout()` confirms via dialog, calls `AuthService.logout()`, then `Get.offAllNamed(Routes.login)` (clears the stack so Back can't return to Home post-logout).
- `profile_view.dart` — displays the logged-in user's name/email, logout button.

### `settings/`
- `settings_controller.dart` — `isDarkMode` reactive flag, restored from `StorageService` on init. `toggleTheme(value)` calls `Get.changeTheme(...)` and persists the choice.
- `settings_view.dart` — a switch bound to `controller.toggleTheme`.

## 10. Shared building blocks (`lib/core/`)

| File | Purpose |
|---|---|
| `constants/app_colors.dart` | All color tokens (brand primary, light/dark surfaces, semantic success/error, note card tint). |
| `constants/app_strings.dart` | Every user-facing string (labels, validation messages, Firebase error copy) — centralized so nothing is hardcoded inline in views/controllers. |
| `theme/app_text_styles.dart` | Helper functions (`regularPoppins`, `mediumPoppins`, `semiboldPoppins`, `boldPoppins`) for consistent Poppins text styling with configurable size/color. |
| `theme/app_theme.dart` | `AppTheme.lightTheme` / `AppTheme.darkTheme` — the two `ThemeData` instances `SettingsController` switches between via `Get.changeTheme`. Defines the global `inputDecorationTheme` (filled fields, rounded borders), `appBarTheme`, `cardTheme`, `elevatedButtonTheme`. |
| `utils/import_to_export.dart` | Barrel file re-exporting `material.dart`, `get.dart`, `google_fonts.dart`, and `app_colors.dart` — most views import just this one file instead of four. |
| `utils/snackbar_util.dart` | `SnackbarUtil.success(msg)` / `.error(msg)` — thin wrapper around `Get.snackbar` so feedback styling (colors, position, duration) is consistent everywhere. |
| `utils/validators.dart` | Static `String? Function(String?)` validators for `TextFormField`s: `email`, `password`, `name`, `confirmPassword` (bound to a live password getter so it re-validates as either field changes), `noteTitle`. |
| `widgets/custom_textfield.dart` | Shared styled `TextFormField` wrapper (label, obscure/visibility, validator, suffix icon). Has its own explicit `border`/`enabledBorder`/`focusedBorder` (visible outline + `floatingLabelBehavior: FloatingLabelBehavior.auto`) so the label animates cleanly above the field on focus instead of the global theme's invisible border making it look cramped. |
| `widgets/custom_button.dart` | Shared primary `ElevatedButton` with an optional loading spinner (disables itself while `isLoading` to prevent double-submits) and optional leading icon. |
| `widgets/note_card.dart` | Renders one `NoteModel` as a `Card`/`ListTile` in Home's list — title, description (2-line clamp), last-updated timestamp, delete icon. |
| `widgets/confirm_dialog.dart` | `showConfirmDialog({title, message})` → `Future<bool>`, used before destructive actions (delete note, logout). |
| `widgets/state_placeholder.dart` | Centered icon + message (+ optional action button) — reused for Home's "no notes yet" empty state and "failed to load" error state. |

## 11. Known GetX gotcha fixed in this codebase

`Get.snackbar(...)` followed immediately by `Get.back()` in the same synchronous block is a documented GetX pitfall: popping the route while the snackbar's overlay entry is still being scheduled can cause **both** the snackbar and the navigation to silently fail (no visible popup, no visible navigation, no thrown error). The fix used throughout this app (Register, Note save) is to **navigate first, then show the snackbar** — GetX snackbars render on a global overlay independent of the route stack, so the message still shows correctly over the destination screen.

## 12. Where to look for common tasks

- **Add a new screen** → create `lib/modules/<name>/{bindings,controllers,views}`, add a `Routes` constant, add a `GetPage` entry in `app_pages.dart`.
- **Add a new Firestore field/collection** → `firestore_service.dart` (data access) + the relevant model in `lib/models/` + `firestore.rules` if access rules need to change.
- **Add a new user-facing string** → `core/constants/app_strings.dart`.
- **Change theme/colors** → `core/constants/app_colors.dart` + `core/theme/app_theme.dart`.
- **Change field/button look app-wide** → `core/widgets/custom_textfield.dart` / `custom_button.dart`.
