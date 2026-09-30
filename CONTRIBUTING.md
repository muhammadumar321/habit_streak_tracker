# Contributing Guidelines

Thank you for contributing to Habityne! Please review these guidelines before submitting code changes.

---

## Branching Strategy

- **`main`**: Production-stable branch. Direct commits to `main` are restricted.
- **`dev`**: Primary active development branch. All new feature work, bug fixes, and refactoring take place on `dev` or feature branches created off `dev`.
- **Feature/Fix Branches**: Name branches descriptively (e.g., `feature/analytics-chart`, `fix/notification-time`).

---

## Development Workflow

1. **Pull Latest Changes**:
   ```bash
   git checkout dev
   git pull origin dev
   ```

2. **Create a Topic Branch** (Optional):
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**:
   - Write clean, documented Dart code.
   - Run `dart format .` before committing.
   - Run `flutter analyze` and resolve all warnings and errors.
   - Add/update unit and widget tests.

4. **Run Verification**:
   ```bash
   dart format --set-exit-if-changed .
   flutter analyze
   flutter test
   ```

5. **Commit Conventions**:
   Use conventional commits:
   - `feat: add habit reminder snooze option`
   - `fix: correct streak calculator edge case for leap years`
   - `docs: update setup guide for JDK 21`
   - `refactor: optimize database query in habit repository`

6. **Submit Pull Request**:
   - Target branch: `dev`.
   - Ensure all automated checks pass before requesting review.
