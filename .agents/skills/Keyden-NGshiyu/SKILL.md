```markdown
# Keyden-NGshiyu Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches the core development patterns and conventions used in the Keyden-NGshiyu Swift codebase. It covers file naming, import/export styles, commit message patterns, and testing approaches. While no specific frameworks or automated workflows are detected, this guide will help you write consistent, maintainable code and understand the project's structure.

## Coding Conventions

### File Naming
- **Style:** PascalCase  
- **Example:**  
  ```swift
  // Good
  UserProfile.swift
  NetworkManager.swift

  // Avoid
  user_profile.swift
  network-manager.swift
  ```

### Import Style
- **Style:** Relative imports  
- **Example:**  
  ```swift
  import Foundation
  import MyModule // if MyModule is a local module
  ```

### Export Style
- **Style:** Named exports  
- **Example:**  
  ```swift
  public class UserProfile { ... }
  public struct NetworkManager { ... }
  ```

### Commit Message Patterns
- **Type:** Freeform (no strict prefixes)
- **Average Length:** ~40 characters
- **Example:**  
  ```
  Add user authentication logic
  Fix bug in data parsing
  Update UI for settings screen
  ```

## Workflows

### Adding a New Feature
**Trigger:** When implementing a new functionality  
**Command:** `/add-feature`

1. Create a new Swift file using PascalCase for the filename.
2. Implement the feature, using relative imports for dependencies.
3. Export classes or structs using named exports.
4. Write corresponding test cases in a `.test.swift` file.
5. Commit your changes with a clear, concise message.

### Fixing a Bug
**Trigger:** When resolving a defect or issue  
**Command:** `/fix-bug`

1. Locate the relevant Swift file(s).
2. Apply the fix, maintaining code style conventions.
3. Update or add test cases in the related `.test.swift` file.
4. Commit with a message describing the fix.

### Writing and Running Tests
**Trigger:** When validating code correctness  
**Command:** `/run-tests`

1. Create or update test files matching the pattern `*.test.swift`.
2. Write test cases for new or changed code.
3. Use the project's preferred method to run tests (framework unknown; check project docs or use `swift test` if using Swift Package Manager).

## Testing Patterns

- **File Pattern:** `*.test.*` (e.g., `UserProfile.test.swift`)
- **Framework:** Unknown (check project documentation)
- **Example:**
  ```swift
  // UserProfile.test.swift
  import XCTest
  @testable import KeydenNGshiyu

  class UserProfileTests: XCTestCase {
      func testUserInitialization() {
          let user = UserProfile(name: "Alice")
          XCTAssertEqual(user.name, "Alice")
      }
  }
  ```

## Commands
| Command       | Purpose                                      |
|---------------|----------------------------------------------|
| /add-feature  | Start a new feature implementation workflow  |
| /fix-bug      | Begin a bugfix workflow                      |
| /run-tests    | Run all test suites in the project           |
```
