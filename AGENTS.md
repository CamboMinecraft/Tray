# Repository Guidelines

## Project Structure & Module Organization
- SwiftPM layout. Key paths:
  - `Package.swift`: defines the `Tray` library target and tests.
  - `Sources/Tray/*.swift`: library source. Group files by feature; one primary type per file.
  - `Tests/TrayTests/*.swift`: test sources using Swift Testing (`import Testing`).

## Build, Test, and Development Commands
- `swift build`: builds in debug. Use `-c release` for optimized builds.
- `swift test`: runs the full test suite. Example: `swift test --filter TrayTests` to narrow scope.
- `swift package resolve`: ensures dependencies are resolved (none currently).
- Xcode: open `Package.swift` in Xcode to develop and run tests via the Test navigator.

## Coding Style & Naming Conventions
- Indentation: 4 spaces; keep lines readable (<120 cols).
- Naming: Types/protocols `UpperCamelCase`; methods/variables `lowerCamelCase`; enum cases `lowerCamelCase`.
- Organization: Prefer small, focused types; keep extensions in feature-appropriate files.
- Formatting: If you use `swift-format`, run `swift-format -i -r Sources Tests` before sending a PR.

## Testing Guidelines
- Framework: Swift Testing (`@Test` functions, `#expect(...)` assertions).
- Structure: Mirror `Sources/Tray` structure under `Tests/TrayTests`.
- Conventions: Test names should read as behavior (e.g., `@Test func parsesValidInput()`).
- Coverage: No gate enforced; include tests for public API and critical paths.

## Commit & Pull Request Guidelines
- Commits: No convention evident in history; prefer Conventional Commits.
  - Examples: `feat(parser): support JSON input`, `fix(cache): avoid stale reads`.
- PRs: include a clear summary, linked issue(s), test updates, and note any API changes. Add screenshots or logs when relevant.

## Security & Configuration Tips
- Toolchain: Package targets Swift tools version 6.1—use a matching toolchain for reproducible builds.
- Dependencies: If adding any, prefer exact versions and justify the choice in the PR description.

