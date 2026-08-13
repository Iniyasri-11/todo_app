import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 9)
        self.setFillColor(colors.HexColor("#4a5568"))
        
        # Header (on all pages except page 1)
        if self._pageNumber > 1:
            self.drawString(54, 750, "Flutter Todo App Completion Report - Viva Study Guide")
            self.setStrokeColor(colors.HexColor("#cbd5e1"))
            self.setLineWidth(0.5)
            self.line(54, 742, 558, 742)
            
        # Footer
        self.setStrokeColor(colors.HexColor("#cbd5e1"))
        self.setLineWidth(0.5)
        self.line(54, 55, 558, 55)
        
        page_text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(558, 40, page_text)
        self.drawString(54, 40, "Confidential - Viva Session Prep Guide")
        self.restoreState()

def create_report():
    pdf_path = "flutter_todo_app_syllabus_completion_report.pdf"
    
    # Page dimensions: letter (612 x 792 pt). Left/right margin 54pt, top/bottom 72pt.
    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=72,
        bottomMargin=72
    )
    
    styles = getSampleStyleSheet()
    
    # Custom Styles (using unique names to avoid conflicts)
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=24,
        leading=30,
        textColor=colors.HexColor('#1e3a8a'),
        spaceAfter=10
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor('#0f766e'),
        spaceAfter=20
    )
    
    h1_style = ParagraphStyle(
        'HourHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=17,
        textColor=colors.HexColor('#0f766e'),
        spaceBefore=12,
        spaceAfter=8,
        keepWithNext=True
    )
    
    label_style = ParagraphStyle(
        'SectionLabel',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=13,
        textColor=colors.HexColor('#1e293b'),
        spaceBefore=4,
        spaceAfter=2,
        keepWithNext=True
    )
    
    body_style = ParagraphStyle(
        'ReportBody',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13,
        textColor=colors.HexColor('#334155'),
        spaceAfter=4
    )
    
    bullet_style = ParagraphStyle(
        'ReportBullet',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13,
        leftIndent=15,
        firstLineIndent=-10,
        textColor=colors.HexColor('#334155'),
        spaceAfter=3
    )
    
    q_style = ParagraphStyle(
        'ReportQuestion',
        parent=styles['Normal'],
        fontName='Helvetica-BoldOblique',
        fontSize=9,
        leading=13,
        textColor=colors.HexColor('#1e3a8a'),
        leftIndent=8,
        spaceBefore=4,
        spaceAfter=2,
        keepWithNext=True
    )
    
    a_style = ParagraphStyle(
        'ReportAnswer',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13,
        textColor=colors.HexColor('#334155'),
        leftIndent=18,
        spaceAfter=5
    )
    
    story = []
    
    # ------------------- COVER PAGE -------------------
    story.append(Spacer(1, 40))
    story.append(Paragraph("FLUTTER OFFLINE-FIRST TODO APP", title_style))
    story.append(Paragraph("20-Hour Complete Syllabus Implementation & Viva Voce Study Guide", subtitle_style))
    story.append(Spacer(1, 20))
    
    intro_text = (
        "<b>Executive Summary:</b> This project documents the complete execution of the 20-Hour "
        "Flutter Application Development curriculum. Over 20 hours of training and pair programming, we "
        "have developed a production-grade, highly responsive, and robust offline-first Todo Management "
        "Application. The app integrates local persistence via SharedPreferences, real-time cloud synchronization "
        "via Supabase database services, state management using Riverpod, and a persistent offline command execution "
        "queue. Every hour's deliverables have been generated, unit-tested, and verified to be 100% complete. "
        "This guide lists how all hours have been completed and provides target questions and answers to assist during your Viva Voce exam session."
    )
    story.append(Paragraph(intro_text, body_style))
    story.append(Spacer(1, 20))
    
    # Project Metadata Table
    metadata_data = [
        [Paragraph("<b>Project Phase</b>", body_style), Paragraph("<b>Syllabus Deliverable Status</b>", body_style)],
        [Paragraph("Hours 1 - 8: Core UI & Forms", body_style), Paragraph("100% Implemented (Form validations, interactive overlays)", body_style)],
        [Paragraph("Hours 9 - 15: Riverpod State & Sync", body_style), Paragraph("100% Implemented (SharedPreferences, Supabase Service)", body_style)],
        [Paragraph("Hours 16 - 20: UI States, Testing & Release", body_style), Paragraph("100% Implemented (11 test suites passing, web build generated)", body_style)],
        [Paragraph("<b>Project Architecture</b>", body_style), Paragraph("Clean Separation of Concerns Pattern (core, models, state, repo, widget)", body_style)]
    ]
    meta_table = Table(metadata_data, colWidths=[180, 324])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (1,0), colors.HexColor('#f1f5f9')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#e2e8f0')),
        ('PADDING', (0,0), (-1,-1), 8),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 40))
    story.append(PageBreak())
    
    # ------------------- HOURLY SYLLABUS BREAKDOWN -------------------
    
    hours_data = [
        {
            "hour": 1,
            "title": "Project Planning & Architecture Spec",
            "concepts": [
                "Product requirements definition (Login, Todo List, Add/Edit, Search, Filters, Settings).",
                "User story mapping and screen routing transitions.",
                "Designing the clean architecture separation of concerns folder structures."
            ],
            "task": "Plan screen flows and design the database schemas and modular multi-tier directories.",
            "deliverable": "Flutter project specifications, database schemas, and folder structures.",
            "files": ["README.md (Project Specifications)", "database_schema.sql (PostgreSQL structure)"],
            "details": "Defined directory layers (core, models, repositories, screens, services, state, widgets) and user interfaces for a secure multi-user tenancy application.",
            "viva_q": [
                ("What does an 'offline-first' architecture mean?", "It means the application primarily reads and writes its active state to a local storage cache first. This guarantees the app is fully functional offline. When the network is available, the repository synchronizes the modifications with the backend server."),
                ("Why is a multi-tier directory structure (core, models, services, etc.) used?", "It enforces the 'Separation of Concerns' principle. This ensures that changes to the UI layer do not break data models or backend service code, making the app highly maintainable, testable, and modular.")
            ]
        },
        {
            "hour": 2,
            "title": "Dart Fundamentals & Data Models",
            "concepts": [
                "Dart basic types, conditions, functions, and dynamic/static declarations.",
                "Classes, objects, constructors, named parameters, and initializers.",
                "Dart Null Safety features (nullable vs non-nullable declarations) and model serialization."
            ],
            "task": "Create the Todo data model supporting serialization and JSON mappings.",
            "deliverable": "Dart Todo data model (`lib/models/todo.dart`).",
            "files": ["lib/models/todo.dart", "lib/models/sync_queue.dart"],
            "details": "Implemented the Todo class with id, title, description, completed, priority (enum), category, and dueDate, complete with a copyWith function, toJson mapping, and fromJson deserializer factory.",
            "viva_q": [
                ("Why is Dart's sound null safety important for data modeling?", "It prevents runtime 'null pointer exceptions' by requiring variables to be explicitly declared as nullable (e.g., 'String?') or non-nullable. If a field is non-nullable, the compiler guarantees it can never contain null."),
                ("What is the purpose of the copyWith method in the Todo model?", "Dart model classes are typically built with final (immutable) fields. Since we cannot modify their fields directly, copyWith creates a new instance of the model with modified fields while keeping the other values unchanged. This is essential for clean state changes in Riverpod.")
            ]
        },
        {
            "hour": 3,
            "title": "Flutter Fundamentals & Main Structure",
            "concepts": [
                "Flutter engine binding, main() entrypoint, and MaterialApp/Scaffold widget concepts.",
                "Understanding the Widget Tree structure and the build() context methods.",
                "Hot Reload versus Hot Restart compile processes."
            ],
            "task": "Create the main entrypoint file and load the dashboard interface.",
            "deliverable": "Initial Flutter widget tree structure (`lib/main.dart`).",
            "files": ["lib/main.dart"],
            "details": "Initialized Flutter engine bindings, initialized Supabase integration credentials asynchronously, and booted the main ProviderScope container that wraps the MaterialApp context.",
            "viva_q": [
                ("Why must we call WidgetsFlutterBinding.ensureInitialized() in main()?", "It is required to initialize the interaction channel between Flutter and the native host OS platform before calling asynchronous native services, such as Supabase services or local storage plugins."),
                ("What is the difference between Hot Reload and Hot Restart in Flutter?", "Hot Reload compiles changed source code files and injects them into the running Dart VM, updating the UI while preserving the active state. Hot Restart compiles changes, destroys the active state, and restarts the app from main(), reset to its initial condition.")
            ]
        },
        {
            "hour": 4,
            "title": "Layout and Widgets",
            "concepts": [
                "Layout primitives: Row, Column, Stack, Padding, Container, and SizedBox.",
                "Expanding layouts using Expanded and Flexible widgets.",
                "Dynamic scrolling views: ListView.builder and Card layouts."
            ],
            "task": "Build a responsive grid/list interface to show Todo tasks on mobile and desktop screens.",
            "deliverable": "Responsive Todo dashboard layout layout structure.",
            "files": ["lib/screens/todos/todo_dashboard.dart"],
            "details": "Implemented a responsive GridView inside the dashboard that dynamically adjusts its column layout (switching to 2 columns on desktop web screens and 1 column on mobile devices).",
            "viva_q": [
                ("Explain the difference between a Column and a ListView.", "A Column renders all its children immediately and does not support scrolling, which causes overflow errors if content exceeds screen bounds. A ListView is scrollable and can render its elements lazily using 'builder', which is highly memory-efficient."),
                ("How does Expanded behave inside a Row or Column?", "Expanded forces a child widget to fill the remaining available horizontal space in a Row, or vertical space in a Column, rather than resizing based on its contents. This prevents overflow warnings.")
            ]
        },
        {
            "hour": 5,
            "title": "User Interaction & Gestures",
            "concepts": [
                "Touch event listeners: GestureDetector vs InkWell ripple widgets.",
                "Interactive triggers: buttons, checkbox status listeners, and list swipes.",
                "Modals and Dialog overlays: showDialog and confirmation sheets."
            ],
            "task": "Implement complete checkmarks, delete overlays, and card details overlays.",
            "deliverable": "Interactive user interactions on the Todo list UI.",
            "files": ["lib/widgets/todo_card.dart", "lib/screens/todos/todo_dashboard.dart (confirmDelete)"],
            "details": "Integrated checkmarks to toggle task completion status, InkWell clicks to trigger edit dialogs, and a styled AlertDialog to prevent accidental task deletions.",
            "viva_q": [
                ("What is the difference between GestureDetector and InkWell?", "GestureDetector is a generic detector for taps, double taps, scales, and drags without rendering visual elements. InkWell is a Material Design widget that adds an active ripple ink animation feedback on top of its child when pressed."),
                ("How do you present an overlay modal dialog in Flutter?", "You invoke 'showDialog', passing the active BuildContext and a builder that returns a widget like an AlertDialog. It creates an overlay route on the screen.")
            ]
        },
        {
            "hour": 6,
            "title": "Forms & Input Validations",
            "concepts": [
                "Form, TextFormField, and TextEditingController widget usages.",
                "Validating user input using GlobalKeys and validation functions.",
                "Date picker integrations and DropdownButton fields."
            ],
            "task": "Create a reusable form component to add and modify Todo task parameters.",
            "deliverable": "Validated input Form overlay (`lib/widgets/todo_form.dart`).",
            "files": ["lib/widgets/todo_form.dart"],
            "details": "Built a TodoForm containing text controllers, validation rules (e.g., titles must be at least 3 characters), category and priority dropdown selectors, and a calendar date picker.",
            "viva_q": [
                ("What is the purpose of the GlobalKey<FormState> in a Form widget?", "The GlobalKey uniquely identifies the Form inside the widget tree. It gives access to its state, enabling us to call 'validate()' to run validator checks, or 'save()' to persist all form values."),
                ("Why is it critical to call dispose() on a TextEditingController?", "TextEditingController is an resource that registers listeners with the OS keyboard services. If we don't call dispose() when the widget is destroyed, it leads to memory leaks.")
            ]
        },
        {
            "hour": 7,
            "title": "State Management with setState",
            "concepts": [
                "Understanding local StatefulWidget widget states and states lifecycle.",
                "Updating user interfaces reactively using the setState() trigger.",
                "Tracking the order of state changes from page load to page disposal."
            ],
            "task": "Establish basic interactive CRUD modifications using StatefulWidget state methods.",
            "deliverable": "Functional local StatefulWidget Todo operations.",
            "files": ["lib/screens/todos/todo_dashboard.dart"],
            "details": "Successfully implemented initial local list alterations using setState calls, tracking completion, search text updates, and dropdown filter parameters before routing state globally.",
            "viva_q": [
                ("What happens under the hood when setState() is called?", "It marks the widget state as 'dirty' and requests the framework to rebuild the widget. Flutter then schedules the widget's build() method to run during the next frame refresh."),
                ("When is setState() NOT suitable for an application?", "When state needs to be shared across multiple screens or components (e.g., auth states needed in a dashboard), or when business logic needs to be isolated for clean unit testing.")
            ]
        },
        {
            "hour": 8,
            "title": "Reusable Components Library",
            "concepts": [
                "Reusability: DRY (Don't Repeat Yourself) component composition.",
                "Passing data via class properties and listening to events via callback functions.",
                "Designing empty placeholders and skeleton screens."
            ],
            "task": "Refactor styling elements into dedicated, reusable widgets.",
            "deliverable": "A reusable widget library (`lib/widgets/`).",
            "files": [
                "lib/widgets/todo_card.dart", "lib/widgets/todo_form.dart", 
                "lib/widgets/empty_state.dart", "lib/widgets/error_state.dart", 
                "lib/widgets/todo_card_skeleton.dart"
            ],
            "details": "Isolated layouts into clean components. Added shimmer skeletons for loading states, double-ring glowing elements for empty workspaces, and error cards with retry features.",
            "viva_q": [
                ("What are the primary benefits of widget composition?", "It maximizes code reuse, simplifies maintenance, and ensures a consistent visual design across the app. Modifying one component (like TodoCard) automatically updates it throughout the application."),
                ("How does a child widget communicate interaction events back to its parent?", "The parent passes a callback function (such as a VoidCallback) to the child via its constructor. When the user interacts with the child, the child invokes that function, notifying the parent.")
            ]
        },
        {
            "hour": 9,
            "title": "State Management Architecture & Riverpod",
            "concepts": [
                "UI State vs Application State vs Business Logic definitions.",
                "Unidirectional data flow models and dependency injection frameworks.",
                "Provider, ChangeNotifierProvider, and StateProvider variations."
            ],
            "task": "Migrate local widget setState code to a decoupled Riverpod architecture.",
            "deliverable": "Decoupled state injection flow (`lib/state/todo_providers.dart`).",
            "files": ["lib/state/todo_providers.dart", "lib/main.dart (ProviderScope)"],
            "details": "Created Riverpod providers that inject the authentication database controller and caching repository directly into screen states, enabling clean unidirectional updates.",
            "viva_q": [
                ("Why is Riverpod preferred over standard setState state methods?", "Riverpod separates business logic and data caching from UI widgets, making the code testable. It also avoids dependency on BuildContext, making it safer to read state."),
                ("What is the function of the ProviderScope widget?", "ProviderScope is a widget that stores the state of all providers in the application. It must wrap the root of the widget tree (MaterialApp) to enable Riverpod.")
            ]
        },
        {
            "hour": 10,
            "title": "Advanced Sorting, Filtering, and Search",
            "concepts": [
                "Combining text search inputs with active filter states.",
                "Sorting list objects dynamically using Dart's compareTo comparators.",
                "Reactively recalculating filtered list displays."
            ],
            "task": "Build multi-parameter filters (Pending, Completed, Priorities) and sorting (Due Date, Priority, Title).",
            "deliverable": "Local query controller UI features in the dashboard.",
            "files": ["lib/screens/todos/todo_dashboard.dart (getFilteredTodos)"],
            "details": "Built a high-performance filtering method that filters the master list by category chips, searches title and description text fields, and sorts items by priority or due dates.",
            "viva_q": [
                ("How is filtering handled reactively in the dashboard?", "The UI watches the repository provider. When the user types a search query or changes a filter chip, setState updates the filter values, and 'getFilteredTodos' recalculates the list dynamically during the rebuild."),
                ("Explain how the comparator method a.dueDate!.compareTo(b.dueDate!) works in Dart.", "It compares two DateTimes. If 'a' is earlier, it returns a negative value; if 'b' is earlier, it returns a positive value; and if they are identical, it returns 0. This is used by list.sort() to sort items.")
            ]
        },
        {
            "hour": 11,
            "title": "Local Storage Caching",
            "concepts": [
                "Data persistence: saving application states locally.",
                "JSON serialization and deserialization maps.",
                "Integrating the SharedPreferences database package."
            ],
            "task": "Configure local caching on the device to enable offline-ready storage capabilities.",
            "deliverable": "Offline persistent todo storage implementation.",
            "files": ["lib/repositories/todo_repository.dart (SharedPreferences)"],
            "details": "Configured local cache files under user-isolated storage keys (e.g. `cached_todos_{user_id}`), translating the list of Todo models into JSON strings for local storage.",
            "viva_q": [
                ("What is the role of the Repository pattern in data management?", "It acts as a clean abstraction layer between the application logic and the storage engines (local database or remote APIs). The UI only requests data from the repository, which determines whether to serve it from cache or fetch it from the API."),
                ("How does SharedPreferences store key-value data on mobile devices?", "It uses platform-specific storage. It writes to XML files on Android, Plist files on iOS, and LocalStorage in web browsers, persisting key-value pairs across sessions.")
            ]
        },
        {
            "hour": 12,
            "title": "HTTP Protocols & REST API Contracts",
            "concepts": [
                "HTTP standards: client requests, server responses, and headers.",
                "REST architecture: resources, endpoints, and HTTP CRUD verbs.",
                "JSON transfer structures and HTTP Status Codes."
            ],
            "task": "Define the API endpoints, request bodies, response payloads, and authorization methods.",
            "deliverable": "Detailed REST API contract specification document.",
            "files": ["api_contract.md"],
            "details": "Authored a complete contract mapping HTTP endpoints (GET, POST, PUT, PATCH, DELETE) for `/todos` and `/auth` routes, specifying response status codes and JWT token headers.",
            "viva_q": [
                ("Explain the HTTP verbs GET, POST, PUT, PATCH, and DELETE.", "GET retrieves a resource; POST creates a new resource; PUT replaces an existing resource; PATCH applies partial updates; and DELETE removes a resource."),
                ("What is the difference between a 401 and a 403 HTTP status code?", "401 Unauthorized means the user lacks credentials and is not authenticated. 403 Forbidden means the user is authenticated but does not have permission to access that resource.")
            ]
        },
        {
            "hour": 13,
            "title": "Remote Database & Supabase API Integration",
            "concepts": [
                "Asynchronous programming: Future, async, and await in Dart.",
                "HTTP and API Client error handling using try-catch blocks.",
                "Integrating real-time cloud data updates using Supabase integration service."
            ],
            "task": "Create the database interface layer to fetch and sync changes with the remote server.",
            "deliverable": "API-connected data synchronization client.",
            "files": ["lib/services/supabase_service.dart"],
            "details": "Created the SupabaseService client supporting real-time subscriptions, secure SQL executions, and guest fallback databases when credentials are not configured.",
            "viva_q": [
                ("What is a Future in Dart, and how is it used with async/await?", "A Future represents a task that will complete in the future (like an API call). The 'async' keyword allows us to write asynchronous code, while 'await' pauses execution until the Future completes, returning the result."),
                ("Why is a try-catch block essential in API client calls?", "API requests can fail due to network timeouts, offline states, or server errors. A try-catch block intercepts these exceptions, preventing crashes and allowing the app to log the error and notify the user.")
            ]
        },
        {
            "hour": 14,
            "title": "Authentication & Data Isolation",
            "concepts": [
                "User authentication: account registration, sign in, and sessions.",
                "Data Isolation: enforcing tenant isolation at database and local storage layers.",
                "Securing database access using Supabase Row Level Security (RLS) rules."
            ],
            "task": "Build Login screens and configure isolated local/remote databases for each user.",
            "deliverable": "Authenticated user interface and secure tenant databases.",
            "files": ["lib/screens/auth/auth_page.dart", "lib/repositories/auth_repository.dart", "auth_flow.md"],
            "details": "Built registration, login, and password reset interfaces. Implemented local storage isolation using `cached_todos_{user_id}` keys, and enabled remote isolation using PostgreSQL RLS policies.",
            "viva_q": [
                ("How does Row Level Security (RLS) enforce tenant isolation in Supabase?", "RLS is a database feature that evaluates policies on each row. For example, a policy like 'auth.uid() = user_id' ensures users can only read or write rows that match their authenticated user ID, blocking unauthorized access."),
                ("How does the app reactively redirect users based on their session status?", "The AuthRepository listens to session events. When a user logs in or out, it notifies Riverpod, which rebuilds the MaterialApp and routes the user to the appropriate page.")
            ]
        },
        {
            "hour": 15,
            "title": "Clean Architecture Refactoring",
            "concepts": [
                "Clean Architecture: modular software layers and Separation of Concerns.",
                "Decoupling the presentation, business logic, data cache, and API network layers.",
                "Organizing code into core, models, screens, widgets, services, repositories, and state directories."
            ],
            "task": "Refactor the codebase into modular directories following clean architecture patterns.",
            "deliverable": "Production-grade, clean Flutter project architecture structure.",
            "files": ["lib/ structure", "walkthrough.md"],
            "details": "Restructured the app into clean folders, separating the UI from business logic. This makes it easy to replace SharedPreferences or Supabase without changing widget code.",
            "viva_q": [
                ("What are the advantages of using Clean Architecture in Flutter?", "It makes the app highly maintainable, testable, and adaptable. Since each layer has a single responsibility, we can mock database services for unit tests, or swap storage libraries without touching the UI."),
                ("How does the repository layer differ from the service layer?", "The service layer handles raw API communication (like Supabase requests). The repository layer coordinates between this API client and local caching, handling offline synchronization.")
            ]
        },
        {
            "hour": 16,
            "title": "Production UI States & Offline Synchronization Queue",
            "concepts": [
                "Simulating offline modes and caching user changes locally.",
                "Building a replay command queue to synchronize offline edits chronological order.",
                "Last-Write-Wins (LWW) resolution for database conflicts."
            ],
            "task": "Implement an offline replication queue, dynamic success/error states, and conflict resolution rules.",
            "deliverable": "Robust offline queue engine and production-ready UI states.",
            "files": ["lib/repositories/todo_repository.dart (syncQueue)", "ui_states.md"],
            "details": "Built an offline command queue. When offline, CRUD tasks are saved to a local queue. When connection is restored, the queue replay engine updates the remote database sequentially.",
            "viva_q": [
                ("What is an optimistic UI update, and how does it improve UX?", "An optimistic update immediately renders the expected result in the UI before receiving confirmation from the server. This removes network lag, making the app feel fast and responsive."),
                ("How does the Last-Write-Wins (LWW) conflict resolution policy work?", "When the app replays offline changes, it compares the 'updatedAt' timestamp of the local change with the database row. The change with the newest timestamp is kept, resolving conflicts.")
            ]
        },
        {
            "hour": 17,
            "title": "Application Debugging & Analysis",
            "concepts": [
                "Debugging tools: Flutter DevTools inspector, CPU profiling, and console logs.",
                "Diagnosing layout constraints and rendering overflow issues.",
                "Handling runtime errors and null-pointer exceptions."
            ],
            "task": "Debug common runtime bugs, identifying their root causes and solutions.",
            "deliverable": "Comprehensive developer debugging guide.",
            "files": ["debugging_checklist.md"],
            "details": "Created a debugging checklist covering common issues like missing ProviderScope wraps, layout overflows, null errors, and connection issues, complete with step-by-step solutions.",
            "viva_q": [
                ("What are Flutter DevTools, and how do they assist in debugging?", "It is a suite of tools for inspecting the widget layout tree, profiling network requests, tracking memory allocations, and profiling performance to identify lag."),
                ("How do you resolve a 'Null check operator used on a null value' error?", "This occurs when applying the '!' operator to a variable that is null at runtime. To fix it, replace '!' with safe alternatives like '??' (null coalescing) or 'if (variable != null)' checks.")
            ]
        },
        {
            "hour": 18,
            "title": "Automated Testing",
            "concepts": [
                "Testing levels: Unit testing vs Widget testing in Flutter.",
                "Creating test mocks for network APIs and database services.",
                "Writing test assertions to verify form validations, search queries, and delete actions."
            ],
            "task": "Build unit and widget test cases to verify core functionality.",
            "deliverable": "11-test suite verifying application features.",
            "files": [
                "test/todo_operations_test.dart", "test/auth_test.dart", 
                "test/sync_test.dart", "test_checklist.md"
            ],
            "details": "Created 11 unit and widget tests. They verify todo creation validation, search text matching, delete modal triggers, auth repository flows, and database isolation keys.",
            "viva_q": [
                ("What is the difference between a Unit Test and a Widget Test in Flutter?", "A unit test verifies the behavior of a single function, method, or class (like model parsing). A widget test renders the UI in a headless testing environment to test layouts and user gestures."),
                ("Why is mocking external APIs important in automated testing?", "It isolates the code being tested. Mocking prevents tests from depending on network stability, API rate limits, or database changes, making them fast and predictable.")
            ]
        },
        {
            "hour": 19,
            "title": "Git & GitHub Best Practices",
            "concepts": [
                "Version control workflows: main branch, feature branches, and pull requests.",
                "Authoring clean semantic commit messages.",
                "CI/CD workflows using GitHub Actions."
            ],
            "task": "Configure git controls and set up GitHub repository configurations.",
            "deliverable": "Git configuration files and semantic commit history.",
            "files": [".gitignore", ".github/workflows/flutter.yml"],
            "details": "Initialized Git versioning, configured clean .gitignore patterns, added GitHub Actions workflow files for build checks, and established semantic commit rules.",
            "viva_q": [
                ("What are semantic commit messages, and why are they helpful?", "They use prefixes (like 'feat:', 'fix:', 'docs:', 'test:') to describe the change. This creates a clean, readable git history and allows for automated release logs."),
                ("What is the purpose of a CI/CD build configuration in Git repositories?", "It automatically runs tests and build checks on every push or pull request. This ensures that new changes do not break the main application branch.")
            ]
        },
        {
            "hour": 20,
            "title": "Build Configurations & Release Deployment",
            "concepts": [
                "Compilation modes: Debug vs Profile vs Release.",
                "Build formats: Android APK/AAB, iOS app bundles, and Web folders.",
                "Production keys, keystores, and distribution platforms."
            ],
            "task": "Create the production release build and document platform deployment guides.",
            "deliverable": "Verified production release web bundle and deployment guide.",
            "files": ["RELEASE.md", "build/web/ (Compiled static files)"],
            "details": "Compiled the application into a production web bundle. Authored a release guide detailing Android Keystore signing and iOS App Store Connect provisioning.",
            "viva_q": [
                ("How does a Release build differ from a Debug build in Flutter?", "A debug build compiles code dynamically for development (enabling hot reload and DevTools). A release build runs tree-shaking, removes asserts/debug symbols, and ahead-of-time (AOT) compiles Dart code for maximum performance."),
                ("What is the difference between an APK and an AAB on Android?", "An APK (Android Package) is a single, installable app file. An AAB (Android App Bundle) is a publishing format sent to the Google Play Store, which dynamically creates optimized APKs tailored to each user's device size and architecture.")
            ]
        }
    ]
    
    # Render Hours sections
    for h in hours_data:
        h_container = []
        # Header
        h_container.append(Paragraph(f"Hour {h['hour']}: {h['title']}", h1_style))
        
        # Concepts
        h_container.append(Paragraph("<b>Key Concepts Covered:</b>", label_style))
        for c in h['concepts']:
            h_container.append(Paragraph(f"&bull; {c}", bullet_style))
            
        # Task
        h_container.append(Paragraph(f"<b>Task Description:</b> {h['task']}", body_style))
        
        # Deliverable
        h_container.append(Paragraph(f"<b>Deliverable:</b> {h['deliverable']}", body_style))
        
        # Files
        files_str = ", ".join(h['files'])
        h_container.append(Paragraph(f"<b>Key Code Files:</b> {files_str}", body_style))
        
        # Implementation Notes
        h_container.append(Paragraph(f"<b>Implementation Notes:</b> {h['details']}", body_style))
        
        # Viva Q&A
        h_container.append(Paragraph("<b>Target Viva Voce Questions & Answers:</b>", label_style))
        for q, a in h['viva_q']:
            h_container.append(Paragraph(f"Q: {q}", q_style))
            h_container.append(Paragraph(f"A: {a}", a_style))
            
        h_container.append(Spacer(1, 10))
        
        # Wrap in KeepTogether to prevent splitting an hour section across pages
        story.append(KeepTogether(h_container))
        
    doc.build(story, canvasmaker=NumberedCanvas)
    print("PDF generated successfully!")

if __name__ == "__main__":
    create_report()
