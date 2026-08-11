# Authentication Flow and User-Specific Data Isolation

This document outlines the **Authentication and Authorization Architecture** implemented in the Todo Management Application, representing the deliverables for **Hour 14**.

---

## 1. Authentication Concepts

* **Authentication (AuthN):** The process of verifying *who* a user is. In this application, users prove their identity by registering/logging in with their email address and password.
* **Authorization (AuthZ):** The process of verifying *what* a user is allowed to do. Once authenticated, users are authorized to perform CRUD operations *only* on their own todo records.
* **Tokens & Session Management:** The client receives a JWT (JSON Web Token) from Supabase upon successful authentication. This token is stored locally to maintain an active session, allowing the user to remain logged in between app launches.

---

## 2. Authenticated Application Flow

The app implements a reactive state-driven user flow using **Riverpod** state management:

```mermaid
graph TD
    Start([App Startup]) --> InitSession{Session Saved?}
    InitSession -- Yes --> Dashboard[Todo Dashboard: Cloud Sync Workspace]
    InitSession -- No --> GuestDashboard[Todo Dashboard: Local Guest Workspace]
    
    GuestDashboard --> ClickLogin[Click "Log In"]
    ClickLogin --> AuthPage[Auth Page]
    
    AuthPage --> Register[Sign Up: New Account]
    AuthPage --> Login[Sign In: Existing Account]
    
    Register -- Success --> Dashboard
    Login -- Success --> Dashboard
    
    Dashboard --> ClickSignOut[Click Settings -> Sign Out]
    ClickSignOut --> GuestDashboard
```

### 2.1. Authentication Screens
* **Auth Page (`lib/screens/auth/auth_page.dart`):** Serves three functional modes:
  * **Sign In:** Takes email + password, verifies credentials.
  * **Sign Up:** Takes email + password + password confirmation, registers new user.
  * **Reset Password:** Sends recovery instruction email to the user.
* **Navigation Guards:** When `AuthRepository.isAuthenticated` turns `true`, the UI reactively redirects to `/dashboard`, hiding guest controls and enabling real-time remote syncing.

---

## 3. Session Management

Authentication states and session persistence are managed reactively inside [AuthRepository](file:///c:/Users/iniya/todo_app/lib/repositories/auth_repository.dart):

```dart
class AuthRepository extends ChangeNotifier {
  String? _userId;
  String? _userEmail;
  bool _isLoading = false;
  
  AuthRepository() {
    _init();
  }

  void _init() {
    // 1. Fetch cached session from Supabase Client / Local Storage
    _userId = SupabaseService.instance.currentUserId;
    _userEmail = SupabaseService.instance.currentUserEmail;

    // 2. Listen to token expiration/refresh/logout events
    _authSubscription = SupabaseService.instance.authStateChanges.listen((userId) {
      _userId = userId;
      _userEmail = SupabaseService.instance.currentUserEmail;
      notifyListeners();
    });
  }
}
```

---

## 4. User-Specific Data Isolation

Data isolation is enforced at both the client and database layers to prevent unauthorized data access:

### 4.1. Client-Side Isolation
The [TodoRepository](file:///c:/Users/iniya/todo_app/lib/repositories/todo_repository.dart) binds data caching directly to the active session:
1. **Isolated Storage Keys:** Cached todos are stored under key `cached_todos_{user_id}`. When a user logs out, the in-memory lists are cleared. If a different user logs in, they only load the cache associated with their user ID.
2. **Offline Queues:** Pending write commands are written to an isolated offline queue (`sync_queue_{user_id}`).

### 4.2. Database-Side Isolation (Supabase RLS)
At the database layer, **Row Level Security (RLS)** is enabled on the `todos` table to guarantee multi-user isolation.
Even if a malicious client modifies their network payload to request another user's todo ID, the database blocks it:

```sql
-- Enable Row Level Security
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

-- Policy: Only allow users to query rows where user_id matches their authenticated UID
CREATE POLICY "Users can view their own todos" 
    ON public.todos FOR SELECT 
    USING (auth.uid() = user_id);

-- Policy: Only allow inserts where the user_id matches the authenticated UID
CREATE POLICY "Users can insert their own todos" 
    ON public.todos FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Policy: Only allow updates where user_id matches authenticated UID
CREATE POLICY "Users can update their own todos" 
    ON public.todos FOR UPDATE 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);
```

---

## 5. Verification: Unit Tests

The authentication logic is validated by unit tests in [auth_test.dart](file:///c:/Users/iniya/todo_app/test/auth_test.dart):

1. **Register and Login Flow Test:**
   * Asserts user starts as unauthenticated.
   * Asserts user successfully registers, automatically logging in and setting email/session parameters.
   * Asserts logout clears the session parameters.
   * Asserts login with registered credentials restores session.
2. **Invalid Password Validation Test:**
   * Registers a test account.
   * Attempts to login with incorrect credentials.
   * Asserts authentication fails, maintaining unauthenticated state, and outputs the expected error message.
