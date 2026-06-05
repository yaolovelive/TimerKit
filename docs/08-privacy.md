# Privacy and compliance

## ATT (App Tracking Transparency)

**Decision: do NOT request ATT permission.**

Reasons:

- No third-party ad SDK
- No third-party analytics (Mixpanel, Firebase Analytics, Amplitude)
- All user data stays in the user's private iCloud
- No cross-app tracking

Skipping ATT preserves a clean first-run flow. Industry data shows
ATT prompts cause 5–15% first-launch attrition. Tact never sees this
loss.

## Privacy Manifest (PrivacyInfo.xcprivacy)

Required since 2024 by Apple. Declare reason codes for any "required
reason API" the app uses.

For Tact:

| API | Reason code | Justification |
|---|---|---|
| `UserDefaults` | `CA92.1` | App functionality |
| File timestamps | `C617.1` | App functionality |

This is a 10-minute task at submission time. Each app target (iOS,
macOS, watchOS) needs its own `PrivacyInfo.xcprivacy`.

## Analytics replacement

Don't ship a third-party analytics SDK. Use Apple's free, built-in
options:

| Need | Solution |
|---|---|
| Crash reports | `MetricKit` — auto-aggregated in App Store Connect |
| Performance metrics | `MetricKit` — battery, hangs, disk usage |
| User feedback (beta) | TestFlight's built-in feedback |
| User feedback (production) | An in-app "Send feedback" button that opens `mailto:` |

Result: zero "we collect xxx data" disclosures, zero SDK integration,
zero privacy footprint.

## App Privacy ("Nutrition Label")

The App Store Connect privacy questionnaire. Most fields will be "Data
Not Collected." The ones that ARE used:

| Category | What's stored | Where |
|---|---|---|
| User Content (notes, timers) | Memos, sessions, configurations | User's private iCloud only |
| Identifiers | Device ID (random UUID) | Local + private CloudKit |

Make sure the questionnaire matches the actual code. Apple does check.

## App Store Review prep

The current master (`michaelvillar/timer-app`) is brew-distributed and
has never been through App Store review. Tact's first submission needs:

### Capabilities to enable

For each app target:

- `com.apple.security.app-sandbox` (mandatory for Mac App Store)
- iCloud + CloudKit, container `iCloud.com.yourbrand.tact`
- Push Notifications
- Background Modes: background fetch, remote notifications
- User Notifications
- App Groups: `group.com.yourbrand.tact`

### Common review rejection reasons

| Rejection | Fix |
|---|---|
| CloudKit container undeclared in App Privacy | Update the privacy questionnaire |
| Missing privacy manifest | Add `PrivacyInfo.xcprivacy` to each target |
| In-app purchase descriptions too brief | Write 80+ word product descriptions |
| Subscription terms not surfaced before purchase | Add ToS link + auto-renewal text |
| Demo account requested | Provide a temporary Apple ID for review |

Plan for one rejection cycle (24–48 h turnaround). First submission
~14 days before intended launch.

## Sensitive memo handling

Memo bodies may contain personal content. They never:

- Get sent to third-party services
- Get included in AI prompts as raw text (only metadata aggregates)
- Get included in crash reports
- Get logged to system console

Verify periodically by grepping for `print(memo.content)` patterns.
