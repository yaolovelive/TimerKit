// MemoStore.swift
//
// Owns memo persistence. Attaches CapturedContext at save time by
// asking TimerEngine and PomodoroScheduler what's currently active.

import Foundation
import SwiftData

@MainActor
public final class MemoStore {
    private let modelContext: ModelContext
    private let detector: CaptureDetector

    public init(modelContext: ModelContext, detector: CaptureDetector = .init()) {
        self.modelContext = modelContext
        self.detector = detector
    }

    /// Save a memo with auto-detected type and the currently active
    /// pomodoro context, if any.
    @discardableResult
    public func save(
        content: String,
        currentPomodoro: PomodoroSession?,
        timeIntoCurrentSession: TimeInterval?
    ) throws -> Memo {
        let detections = detector.detect(content)
        let type = detections.primaryMemoType
        let context = CapturedContext(
            pomodoroID: currentPomodoro?.id,
            taskTitle: currentPomodoro?.taskTitle,
            tagName: currentPomodoro?.tag?.name,
            timeIntoSession: timeIntoCurrentSession
        )

        let memo = Memo(
            content: content,
            detectedType: type,
            capturedContext: currentPomodoro != nil ? context : nil,
            tag: currentPomodoro?.tag
        )
        modelContext.insert(memo)
        try modelContext.save()
        return memo
    }

    /// Auto-archive memos older than 30 days that are unpinned and
    /// untouched. Call from a periodic BGAppRefreshTask.
    public func archiveStale(cutoff: Date = Date().addingTimeInterval(-30 * 86400)) throws {
        var descriptor = FetchDescriptor<Memo>(
            predicate: #Predicate { memo in
                memo.createdAt < cutoff && !memo.archived
            }
        )
        descriptor.fetchLimit = nil
        let staleMemos = try modelContext.fetch(descriptor)
        staleMemos.forEach { $0.archived = true }
        if !staleMemos.isEmpty {
            try modelContext.save()
        }
    }

    /// Archive a memo without deleting its captured data.
    public func archive(_ memo: Memo) throws {
        memo.archived = true
        try modelContext.save()
    }

    /// Permanently delete a memo when the user explicitly requests it.
    public func delete(_ memo: Memo) throws {
        modelContext.delete(memo)
        try modelContext.save()
    }
}
