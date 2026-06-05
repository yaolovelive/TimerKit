# Design System

## Three principles

### 1. Time is the hero

A single, massive, readable time numeral is always the focal point of
the main view. 48 pt minimum on watchOS, scaling up to 160 pt on macOS.
SF Pro Rounded Semibold, with monospaced digits to prevent
character-width jitter as numbers change. No tabs, no sidebar, no
top-level navigation. Other features (pomodoro flow, capture, stats)
are reachable via gesture or keyboard shortcut, not exposed as UI
hierarchy.

### 2. State is environment

The background color of the main view shifts to communicate session
state. No state-switching pages, no labels needed at a glance.

| State | Background tint | Meaning |
|---|---|---|
| Idle | Warm neutral gray | Ready, nothing running |
| Focus | Cool teal-green | Work session in progress |
| Short break | Warm amber | Earned rest |
| Long break | Deeper green | After 4 cycles |
| Capture | Violet | Memo panel is active |

The transition between states is a 0.4-second smooth animation, not an
abrupt cut. State drives ambient detail too: the subtle pulse of the
progress ring, the brightness of the wallpaper-style gradient.

### 3. One-touch reach

- **macOS**: `Space` = start/pause, `R` = reset, `⌥ Space` = capture
  panel, `⌘N` = new timer
- **iOS**: primary actions in the bottom half for thumb reach; long
  press for power features
- **watchOS**: tap to start/pause, Digital Crown to adjust duration,
  side button assigned to capture (user-configurable)

If any feature requires more than one interaction from rest, that
feature gets a keyboard shortcut or gesture.

## Typography

| Use | Font | Notes |
|---|---|---|
| Time numerals | SF Pro Rounded Semibold | Monospaced digits |
| Section titles | SF Pro Text Medium | 18 pt macOS, 16 pt iOS |
| Body | SF Pro Text Regular | 15 pt |
| Labels | SF Pro Text Medium | 12 pt, sentence case |
| Captions | SF Pro Text Regular | 11 pt minimum |

## Spacing

4 pt baseline. Steps: 4 / 8 / 12 / 16 / 24 / 32 / 48.

## Corners

Continuous curvature (Apple's squircle).

| Element | Radius |
|---|---|
| Window | 16 pt |
| Card | 12 pt |
| Button | 8 pt |
| Pill / chip | full radius |

## Surfaces

Use Apple's current Liquid Glass treatment with 30–50 pt blur. Do not
apply to the watchOS UI — too small to read; use solid color tints
instead.

## Motion

| Transition | Duration | Curve |
|---|---|---|
| State change (background shift) | 0.4 s | `smooth` |
| Number flip | 0.2 s | `easeOut` |
| Capture panel appear | 0.35 s | `spring` (response 0.35, damping 0.85) |
| Pomodoro dot fill | 0.25 s | `easeInOut` |

Never use bounce animations. The product is calm.

## Iconography

System SF Symbols only. No custom illustrations except the app icon.
Outline weight by default, filled weight when active.

## Don't

- Liquid Glass on watchOS (illegible at small sizes)
- Bounce animations
- Multiple accent colors on screen at once
- Drop shadows (use Liquid Glass blur for depth instead)
- Tabs in the main view
- Onboarding tooltips after week 1
