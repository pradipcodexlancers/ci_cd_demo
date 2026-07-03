/// All user-facing text lives here so copy changes / future localization
/// don't require hunting through widget files.
class AppStrings {
  AppStrings._();

  static const String appName = 'Notes App';

  // Splash
  static const String splashTagline = 'Your thoughts, organized.';

  // Login
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Login to continue';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String login = 'Login';
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String loginSuccess = 'Login successful';
  static const String loginFailed = 'Invalid email or password';
  static const String dontHaveAccount = "Don't have an account?";
  static const String registerNow = 'Register now';

  // Firebase Auth error messages (mapped from FirebaseAuthException.code in AuthService)
  static const String emailAlreadyRegistered = 'This email is already registered';
  static const String accountDisabled = 'This account has been disabled';
  static const String tooManyAttempts = 'Too many attempts. Please try again later';
  static const String networkError = 'Network error. Check your connection';
  static const String genericAuthError = 'Something went wrong. Please try again';

  // Register
  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Sign up to start taking notes';
  static const String name = 'Name';
  static const String confirmPassword = 'Confirm Password';
  static const String register = 'Register';
  static const String nameRequired = 'Name is required';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String passwordMismatch = 'Passwords do not match';
  static const String registerSuccess = 'Account created - please login';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String loginNow = 'Login';

  // Home
  static const String home = 'Home';
  static const String searchNotes = 'Search notes...';
  static const String noNotesYet = 'No notes yet. Tap + to add one.';
  static const String noResultsFound = 'No notes match your search.';
  static const String errorLoadingNotes = 'Something went wrong while loading your notes.';
  static const String retry = 'Retry';
  static const String sortBy = 'Sort by';
  static const String sortNewest = 'Newest first';
  static const String sortOldest = 'Oldest first';
  static const String sortTitleAz = 'Title (A-Z)';

  // Add / Edit note
  static const String addNote = 'Add Note';
  static const String editNote = 'Edit Note';
  static const String noteTitle = 'Title';
  static const String noteDescription = 'Description';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String deleteNoteConfirm = 'Are you sure you want to delete this note?';
  static const String titleRequired = 'Title is required';
  static const String noteAdded = 'Note added';
  static const String noteUpdated = 'Note updated';
  static const String noteDeleted = 'Note deleted';
  static const String noteSaveFailed = 'Failed to save note. Please try again';
  static const String noteDeleteFailed = 'Failed to delete note. Please try again';

  // Profile
  static const String profile = 'Profile';
  static const String logout = 'Logout';
  static const String logoutConfirm = 'Are you sure you want to logout?';

  // Settings
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String darkModeSubtitle = 'Toggle app theme';
  static const String about = 'About';
}
