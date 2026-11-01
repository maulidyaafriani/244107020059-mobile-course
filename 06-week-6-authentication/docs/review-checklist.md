# Mid-project review checklist

**Status: in progress — not ready to mark as passed.** The local static
analysis and tests pass, but the reviewed feature has not been linked to a
peer-reviewed, merged PR, and some mid-review evidence is still missing.

## Readiness

| Requirement | Status | Evidence / next action |
|---|---|---|
| Feature-first architecture and three week-7 cleanliness checks | Pass (scope documented) | Reran the three checks: domain imports no Flutter/Dio/SQLite/Firebase; pages/presentation import no raw models/DTOs/responses; pages and state providers construct no repository implementation. One `AuthRepositoryImpl` construction remains in the designated Riverpod DI provider, which is the intended composition point. Commands and results are in the README. |
| Static analysis | Pass | `flutter analyze` completed with no issues in `06-week-6-authentication`. |
| Tests | Pass | `flutter test` completed successfully (19 tests). |
| Dart formatting | Pass, with local build-tree caveat | Dart formatting was applied to the project sources and `dart format --set-exit-if-changed lib test` passes. The full `.` command hits a stale generated path under the local ignored `build/`; CI runs the full check before creating build artifacts. |
| Small PR and clear commits | In progress | Current branch: `feat/auth-validation`, based on `develop`; feature diff is 59 lines and the requested issue is [#1 Validasi input login](https://github.com/maulidyaafriani/244107020059-mobile-course/issues/1). Open the PR with `Closes #1`, then record its URL and merge commit after review and merge. |
| README, screenshots, and run instructions | Partial | README contains Chrome run instructions and screenshots are present in `secrenshoot/`. The FCM matrix now explicitly records that foreground/background/terminated were not manually tested in this review. Perform those Firebase Console checks and add observed results/screenshots. |
| Review comments followed up | In progress | Three actionable comments were addressed locally: reject malformed domain labels, assert the exact short-password message, and cover null passwords. The email-regex fix was demonstrated by a regression test that failed before the fix. Decisions and proof are in `docs/ai-review-vs-keputusan.md`. Add these replies to the actual PR and request re-review; a human reviewer has not approved this branch yet. |
| README mid-semester status and issue/PR map | Partial | The README now links issue #1 and records that a PR remains to be created. Add the PR URL and reviewer after the PR exists. |

## Local verification

Run from `06-week-6-authentication/`:

```powershell
flutter analyze
dart format --set-exit-if-changed lib test
flutter test
```

All three commands passed on the source tree (19 tests). The full recursive
formatter command also passed after excluding the stale ignored local `build/`
tree; CI checks the full project on a clean checkout before build artifacts
exist. The behavior of login and push notifications has not been manually
compared against the end-of-week-7 app in this review.

## Completion criteria

Mark the mid-review as passed only after all of the following are true:

- The app has been checked against the end-of-week-7 behavior.
- The three week-7 cleanliness checks are rerun and their evidence is recorded.
- Formatting, analysis, and tests pass locally and in CI.
- At least one small PR per pair has been reviewed and merged.
- At least three meaningful review comments have been answered and the branch
  has received approval before merging.
- The README contains the mid-semester status and links to the related issues
  and PRs.
- All review comments are resolved and the FCM test matrix reflects observed
  outcomes.
