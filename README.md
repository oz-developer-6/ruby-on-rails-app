# School and Student Homework Marking System

A Ruby on Rails application for managing schools, enrolling students, publishing homework assignments, and marking/grading student submissions.

## Architecture and Domain Model

- **School**: Represents educational institutions with unique name and uppercase code.
- **Student**: Belongs to a school with enrollment identifier, full name, email, and academic performance tracking.
- **Homework**: Belongs to a school with title, subject, maximum score, and due date. Supports bulk assignment across enrolled school students.
- **Marking**: Tracks homework submission grading for each student, calculating score percentages, letter grades (A, B, C, D, F), pass/fail status, and feedback cycles (marked, pending, resubmission required).
- **Database**: In-line file-based SQLite database (`storage/development.sqlite3` and `storage/test.sqlite3`).

## Running the Application

1. Install dependencies:
   ```bash
   bundle install
   npm install
   ```

2. Setup database and seed data:
   ```bash
   bin/rails db:migrate
   bin/rails db:seed
   ```

3. Start Rails server:
   ```bash
   bin/rails server
   ```
   Open `http://localhost:3000` in your browser.

## Running Tests

### RSpec Unit and Database Integration Tests

Run the full RSpec suite:
```bash
bundle exec rspec
```

Run only model unit specs:
```bash
bundle exec rspec spec/models
```

Run database integration and transactional consistency tests:
```bash
bundle exec rspec spec/integration
```

Run request/controller CRUD specs:
```bash
bundle exec rspec spec/requests
```

### End-to-End Gherkin Tests with Playwright

Run end-to-end tests:
```bash
npm test
```
