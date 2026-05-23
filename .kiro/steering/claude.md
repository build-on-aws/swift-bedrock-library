## Pre-commit formatting

Always run `swift format` on any modified Swift files before committing. This ensures consistent code style across the project.

When preparing a commit:
1. Identify all `.swift` files that have been modified.
2. Run `swift format -i <file>` on each modified file.
3. Then stage and commit the changes.
