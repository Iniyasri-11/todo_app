# Todo Management App - Test Suite & Verification Checklist

This document describes the testing architecture, mocking strategy, and detailed verification checklist for the Todo Management Application.

---

## 1. Testing Architecture & Mocking Strategy

The application implements a hermetic testing strategy, ensuring tests execute quickly, consistently, and without requiring a live internet connection or a real database instance:

* **SharedPreferences Mocking:** Local disk cache is mocked using Flutter's `SharedPreferences.setMockInitialValues({})`. This provides a clean, sandboxed key-value store for each test.
* **Supabase Service Mocking:** Network database queries are intercepted by substituting the real client with `MockSupabaseService`. This mock simulates a live Postgres instance, managing a memory-backed schema containing tables for `todos` and `users`.
* **Riverpod Provider Injection:** For widget testing, Riverpod's `ProviderScope(overrides: [...])` is leveraged to inject pre-authenticated repositories directly into the widget tree.

---

## 2. Comprehensive Verification Checklist

### 🟩 Phase 1: Authentication Tests
- [x] **Registration:** Verify that registering a user generates a valid UUID and updates the auth state.
- [x] **Login:** Verify that logging in with correct credentials updates user email and isolation states.
- [x] **Validation:** Verify that signing in with an incorrect password triggers a clean error message and fails validation.

### 🟨 Phase 2: Synchronization & Offline-First Engine
- [x] **Optimistic Updates:** Verify adding/updating/deleting tasks immediately updates the local UI before network response.
- [x] **Write Queueing:** Verify that operations done while offline are serialized into a persistent queue.
- [x] **Auto-Synchronization:** Verify that toggling offline simulator to online triggers the replay engine, pushes the queue, and syncs remote records.
- [x] **Last-Write-Wins Conflict Resolution:** Verify that during sync conflicts, the newer record (based on `updatedAt`) overrides the older record.
- [x] **Multi-user Isolation:** Verify that guest cache, developer cache, and student cache are isolated, preventing other users from reading cached data.

### 🟦 Phase 3: Model Serialization
- [x] **JSON Serialization:** Verify `Todo.toJson()` correctly maps fields.
- [x] **JSON Deserialization:** Verify `Todo.fromJson()` parses database timestamps, priority enums, and null descriptions.

### 🟧 Phase 4: UI Operations & Edge Cases (New Suite)
- [x] **Empty Title Validation:** Verify attempting to save a blank task highlights field validation: `Title is required`.
- [x] **Minimum Character Constraint:** Verify task title length constraints trigger errors: `Title must be at least 3 characters`.
- [x] **Successful Creation:** Verify entering a valid title closes dialog overlays and prints the card to the workspace grid.
- [x] **Task Completion Toggle:** Verify ticking task checkboxes successfully changes status and updates lists.
- [x] **Priority Filtering:** Verify ChoiceChips (High/Medium/Low) filter cards correctly.
- [x] **Completion Filtering:** Verify sorting list by All/Pending/Completed yields accurate results.
- [x] **Interactive Search:** Verify entering search text displays match results and filters other cards.
- [x] **Search Empty State:** Verify searching for non-existent terms renders the premium empty state page.
- [x] **Accidental Delete Protection:** Verify clicking delete opens a polished dialog box and clicking `Cancel` preserves the task card.
- [x] **Confirmed Deletion:** Verify confirming delete inside overlay removes task card from UI list and syncs delete flags.
