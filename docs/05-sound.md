# Sound and haptics

## Why sound matters here

Sound is the most overlooked aspect of productivity app design and
has outsized impact on perceived quality. A timer ending with a stock
"ding" feels cheap regardless of how good the visuals are. A single,
considered note instantly bumps the product into the "high-quality
tool" bucket.

## The 1.2-second rule

All session-end sounds must complete (including reverb decay) within
**1.2 seconds**. Reason: users run pomodoros back-to-back. A 5-second
ceremonial bell feels great on play #1, annoying by play #3, and the
reason people uninstall by play #10. 1.2 s is the empirical threshold
where the sound retains charm at high frequency.

## Free-tier end sounds (3)

| Name | Character | When to suggest |
|---|---|---|
| Chime | Soft mallet on metal, 1.2 s decay, warm overtones | Default |
| Bell | Small ceremonial bell, 1.0 s decay, clear and brighter | Users who like a more formal feel |
| Silent | No audio at all — Watch haptic only | Office, theater, library, quiet hours |

**Silent is a first-class option, not a placeholder.** Many users
work in environments where any external sound is forbidden. They
should not feel like they're "missing out" by picking Silent.

## End sound variants per transition

Same base assets, slight modulation:

| Transition | Sound |
|---|---|
| Work → break | Chime base, gentle |
| Break → work | Chime with sharper attack, slight alerting |
| 4-cycle complete | Chime + small pitch-up tail (small flourish) |
| Long break starts | Chime + warmer reverb |

Pitch and reverb adjustments are done at runtime via `AVAudioEngine`,
no need to record separate stems.

## Pro tier white-noise pack

15 tracks, ~60–120 s each, seamless loops, AAC 48 kHz / 16-bit.
Total bundle ~30 MB, downloaded on demand after Pro purchase.

| Category | Tracks |
|---|---|
| Nature | Light rain · Heavy rain · Wind through trees · Ocean waves · Forest morning |
| Spaces | Coffee shop · Library hum · Train cabin · Night crickets |
| Tonal | Brown noise · Brown + low rumble · Pink noise · Tape hiss & vinyl |
| Meditative | Singing bowl · Distant chimes |

Sourcing: license from Splice / Pond5 (CC0 or commercial). Don't
record yourself unless you have proper field-recording gear. Budget
roughly $400–700 USD for the full pack.

## Watch haptic vocabulary

The user learns to recognize these without looking:

| Event | Haptic |
|---|---|
| Session start | `.start` — single light tap |
| Work segment complete | `.success` — double tap ascending |
| Break segment complete | `.notification` — three quick taps |
| 4-pomodoro cycle complete | Custom `CHHapticPattern` — three quick + one long |
| Memo synced to cloud | `.click` — very light, barely felt |

See `Sources/TimerKit/Sound/HapticPattern.swift` for the
`CHHapticEngine` implementation of the cycle-complete pattern.

## Technical implementation

```swift
// One-shot end sounds — minimal latency, simple
private var endPlayer: AVAudioPlayer?
func playEnd(_ sound: EndSound) {
    try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
    endPlayer = try? AVAudioPlayer(contentsOf: sound.url)
    endPlayer?.play()
}

// White noise loops — gapless looping with crossfade
private let engine = AVAudioEngine()
private var player = AVAudioPlayerNode()
func startWhiteNoise(_ track: WhiteNoise, crossfadeFrom: WhiteNoise? = nil) {
    try? AVAudioSession.sharedInstance().setCategory(
        .playback, mode: .default, options: [.mixWithOthers]
    )
    // ... configure player node, schedule buffer for infinite loop,
    //     800ms crossfade if switching from another track
}
```

iOS `AVAudioSession` categories matter:

- **End sounds:** `.ambient` — yields to music, respects silent switch
- **White noise:** `.playback` + `.mixWithOthers` — keeps playing
  alongside user's Spotify, doesn't take audio focus

macOS: no `AVAudioSession`, just play.

## Respect system Focus / Do Not Disturb

Critical. A single inappropriate beep in a meeting and the user
uninstalls.

- macOS: observe `NSWorkspaceDidChangeFocusModes`, mute external audio
  when any Focus mode is active. Visual state changes still happen.
- iOS: set `UNNotificationInterruptionLevel` to `.active` (not
  `.timeSensitive`), so system Focus filters can silence Tact
- watchOS: Theater Mode automatically silences output; respect it

## Asset bundling

```
Resources/Sounds/
  end-chime.m4a        # ~50 KB
  end-bell.m4a         # ~50 KB
  wn-light-rain.m4a    # ~1.5 MB
  wn-heavy-rain.m4a
  wn-wind.m4a
  ... (15 white noise files total)
```

End sounds ship with all builds. White noise pack downloads on demand
after Pro purchase via `BackgroundDownloadTask`.
