// VoiceTranscriptTests.swift

import Foundation
import Testing
@testable import TimerKit

struct VoiceTranscriptTests {
    @Test func collapsesDoubledSpacesAndTrims() {
        #expect(VoiceTranscript.normalize("  ship   the  watch app ") == "ship the watch app")
    }

    @Test func flattensNewlinesIntoSingleSpaces() {
        #expect(VoiceTranscript.normalize("call Ana\n\nabout #tact") == "call Ana about #tact")
    }

    @Test func rejectsWhitespaceOnlyTranscripts() {
        #expect(VoiceTranscript.normalize("   \n  ") == nil)
        #expect(VoiceTranscript.normalize("") == nil)
    }

    @Test func leavesCleanTextAlone() {
        #expect(VoiceTranscript.normalize("draft the P4 sync plan") == "draft the P4 sync plan")
    }
}
