// TimerEngine.swift
//
// The ObservableObject that drives the timer view. Decoupled from
// platform-specific UI: macOS uses AppKit-drawn views, iOS/watchOS use
// SwiftUI. All three observe the same engine instance.
//
// Implementation strategy: don't poll a heartbeat for display. Instead,
// publish state changes (start/pause/complete) and compute the displayed
// time on demand from the bound TimerSession. The View layer is
// responsible for redrawing every second using a Timer.publish loop
// scoped to its own lifecycle.

import Combine
import Foundation
import Observation

@Observable
public final class TimerEngine {
    public private(set) var activeSession: TimerSession?
    public private(set) var lastTickAt: Date = Date()

    private var heartbeat: AnyCancellable?

    public init() {}

    // MARK: - Lifecycle

    public func start(_ session: TimerSession) {
        activeSession = session
        scheduleHeartbeat()
    }

    public func pause() {
        guard let session = activeSession, session.state == .running else { return }
        session.state = .paused
        session.pauseHistory.append(PauseRecord(pausedAt: Date()))
        heartbeat?.cancel()
    }

    public func resume() {
        guard let session = activeSession, session.state == .paused else { return }
        if let lastPause = session.pauseHistory.last, lastPause.resumedAt == nil {
            var updated = lastPause
            updated.resumedAt = Date()
            session.pauseHistory[session.pauseHistory.count - 1] = updated
        }
        session.state = .running
        scheduleHeartbeat()
    }

    public func cancel() {
        guard let session = activeSession else { return }
        session.state = .cancelled
        heartbeat?.cancel()
        activeSession = nil
    }

    public func complete() {
        guard let session = activeSession else { return }
        session.state = .completed
        heartbeat?.cancel()
        // Caller is responsible for emitting end-of-session sound + haptic.
    }

    // MARK: - Heartbeat

    private func scheduleHeartbeat() {
        heartbeat?.cancel()
        heartbeat = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.lastTickAt = now
                self?.checkExpiry(at: now)
            }
    }

    private func checkExpiry(at now: Date) {
        guard let session = activeSession, session.state == .running else { return }
        if session.remaining(at: now) <= 0 {
            complete()
        }
    }
}
