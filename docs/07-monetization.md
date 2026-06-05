# Monetization

## Three-tier structure

| Tier | Price | Includes |
|---|---|---|
| Free | ¥0 | Single timer, standard pomodoro, ≤50 memos, today's stats |
| Premium (one-time) | ¥98 / $14.99 | Unlimited timers and memos, all stats, sound and theme packs, CloudKit sync, Family Sharing |
| Pro (subscription) | ¥18/mo or ¥128/yr | AI weekly report, smart focus suggestions, white noise expansion, future premium features |

The core sale is **Premium one-time.** This matches utility-app user
expectations on the Apple ecosystem. Pro subscription is for genuinely
heavy users.

## Why not pure subscription

The pomodoro app market is saturated (Forest, Be Focused, Session,
Flow) and price-competitive. Pure subscription doesn't work for new
entrants. Mac and Watch users are especially subscription-averse for
this category.

## Why not pure buyout

CloudKit storage costs, the future cost of AI features if they go
cloud-based, and the $99/year Apple Developer Program fee need ongoing
revenue to sustain. Pro at ¥128/year isn't about making it big — it's
about retaining the will to fix bugs.

## Price anchors (researched)

| App | Pricing model |
|---|---|
| Things 3 | ¥68 iOS / ¥348 Mac, pure one-time |
| Bear | ¥98/yr subscription |
| Forest | ¥12–25 buyout + cosmetic IAP |
| Be Focused | Free + ¥35 IAP |
| Session | Pure subscription ¥35/mo |

Tact at ¥98 buyout for three-platform support including a real Watch
app is fair-priced compared to single-platform alternatives.

## App Store Connect configuration

| Setting | Value |
|---|---|
| Universal Purchase | ON — one purchase unlocks iOS, macOS, Watch, iPad |
| Family Sharing | ON for Premium, ON for Pro |
| Pro introductory offer | 7-day free trial |
| Pro promotional offers | TBD — for win-back campaigns |

## ASO essentials

| Field | Strategy |
|---|---|
| App name | "Tact" (just the name) |
| Subtitle | "Focus and capture" or "Calm focus timer" |
| Keywords | timer, pomodoro, focus, memo, productivity, watch |
| Categories | Primary: Productivity. Secondary: Health & Fitness |

Five App Store screenshots, in this order:

1. Hero — main timer view in focus state (vertical, big numerals)
2. Pomodoro flow — showing the work/break sequence with state colors
3. Quick capture — the memo panel with detection chips
4. Apple Watch — complication on a watch face
5. AI weekly report — the literary report design

## Revenue model — Year 1 projection

Assumptions:

- 5,000 downloads in 60 days post-launch
- Premium conversion 8% = 400 × ¥98 = ¥39,200
- Pro yearly conversion 1.5% = 75 × ¥128 = ¥9,600
- Apple commission Y1: 30% on both

Gross: ¥48,800. After Apple cut: ~¥34,160 first year. Pro Y2+ Apple
commission drops to 15%, so retention drives compounding revenue.

## Launch pricing

Consider a launch-week 50% off on Premium (¥49) to drive Product Hunt
+ Apple feature consideration. Limited to first 7 days, not as a
permanent discount cycle.

## Refunds

Apple handles all refunds, no developer policy needed. Customer
service inquiries about refunds: redirect to Apple's reportaproblem.

## What about Apple Search Ads

Skip Y1. ASA cost-per-install in productivity is high ($3–8 USD on
average). Better to invest the same dollars into press outreach,
Product Hunt launch, and influencer copies. Reconsider ASA in Y2 once
you have organic baseline data.
