# School and Student Homework Marking System

A Ruby on Rails application for managing schools, enrolling students, publishing homework assignments, and marking/grading student submissions.

## Design Philosophy

- **Self-Documenting Codebase**: Zero comments throughout the application code, specs, and features. Method and variable names are explicitly defined to describe intent and domain operations directly.
- **In-Line Database**: Configured with file-based SQLite (`storage/development.sqlite3` and `storage/test.sqlite3`) for MVP development and automated testing.

## Domain Model and Capabilities

### School (`app/models/school.rb`)
- Represents educational institutions with unique name and uppercase code.
- Has many students and homeworks with cascading deletions (`dependent: :destroy`).
- Computes aggregate statistics across all students: `student_count`, `homework_count`, `average_score`, and `completion_rate_percentage`.

### Student (`app/models/student.rb`)
- Belongs to a school with enrollment identifier, full name, and email validation.
- Tracks individual academic performance: `full_name`, `average_score`, `completion_rate_percentage`, and `passed_markings_count`.

### Homework (`app/models/homework.rb`)
- Belongs to a school with title, subject, maximum score, and due date.
- Methods include `overdue?`, `average_score`, `average_percentage`, and `completion_rate_percentage`.
- Supports one-click bulk assignment to all currently enrolled students via `assign_to_all_school_students!`.

### Marking (`app/models/marking.rb`)
- Associates a student with a homework assignment.
- Enforces uniqueness per student/homework pair and ensures the student and homework belong to the same school.
- Manages submission statuses: `pending`, `marked`, and `resubmission_required`.
- Validates score ranges against homework maximum score.
- Computes `percentage`, `passed?` (score >= 50%), and letter grades (`A`, `B`, `C`, `D`, `F`).
- Methods for grading workflows: `mark!(given_score, given_feedback)` and `require_resubmission!(given_feedback)`.

## Web Interface and Controllers

- **Dashboard** (`app/controllers/dashboard_controller.rb`): High-level system statistics (total schools, students, homeworks, completed vs. pending markings) and recent submission activity.
- **Schools** (`app/controllers/schools_controller.rb`): Full CRUD for schools with student and homework rosters.
- **Students** (`app/controllers/students_controller.rb`): Student enrollment, profiles, and historical submission grades with school filtering.
- **Homeworks** (`app/controllers/homeworks_controller.rb`): Publishing homework, viewing class performance, and assigning homework to all students.
- **Markings** (`app/controllers/markings_controller.rb`): Recording marks, score allocations, qualitative teacher feedback, and resubmission requests.
- **UI Styling** (`app/assets/stylesheets/application.css`): Responsive dashboard cards, status badges, metrics grids, and clean tabular data views.

## Running the Application

1. Install dependencies:
   ```bash
   bundle install
   npm install
   ```

2. Setup database and seed sample data:
   ```bash
   bin/rails db:migrate
   bin/rails db:seed
   ```

3. Start Rails server:
   ```bash
   bin/rails server
   ```
   Open `http://localhost:3000` in your browser.

## Testing Suite

### 1. RSpec Suite (76 Examples, 0 Failures)

The RSpec suite verifies model validations, business logic, controller request cycles, and database constraints.

- **Run all RSpecs:**
  ```bash
  bundle exec rspec
  ```

- **Run model unit tests:**
  ```bash
  bundle exec rspec spec/models
  ```
  - `spec/models/school_spec.rb`: Validations, uppercase code normalization, cascading destruction, and school averages.
  - `spec/models/student_spec.rb`: Email formatting, enrollment number uniqueness, GPA calculation, and pass rates.
  - `spec/models/homework_spec.rb`: Overdue date checks, average score aggregation, and bulk class assignment.
  - `spec/models/marking_spec.rb`: Score bounds, status transitions, percentage calculation, and letter grade brackets.

- **Run database integration tests:**
  ```bash
  bundle exec rspec spec/integration
  ```
  - `spec/integration/database_constraints_spec.rb`: Database-level foreign key enforcement, unique compound indexes, and transactional rollbacks.
  - `spec/integration/school_marking_workflow_spec.rb`: End-to-end database lifecycle from school registration to grading and resubmissions.

- **Run request / controller tests:**
  ```bash
  bundle exec rspec spec/requests
  ```
  - CRUD operations, redirects, status codes, and flash notices across all controllers.

### 2. End-to-End Gherkin Tests with Playwright (5 Scenarios, 67 Steps, 100% Passing)

Driven by `@cucumber/cucumber` and headless Chromium via `playwright`:

- **Run end-to-end Gherkin tests:**
  ```bash
  npm test
  ```

- **Feature files:**
  - `features/school_management.feature`: Creating schools and verifying form validations.
  - `features/student_enrollment.feature`: Enrolling students into schools.
  - `features/homework_marking.feature`: Publishing homework, assigning to all students, and recording grades with teacher feedback.

- **Support & Step Definitions:**
  - `features/support/env.js`: Automated Rails test server lifecycle management and Playwright browser orchestration.
  - `features/step_definitions/steps.js`: Gherkin step implementations interacting directly with browser elements.
