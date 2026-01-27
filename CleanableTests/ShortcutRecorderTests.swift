import AppKit
@testable import Cleanable
import Foundation
import Testing

@Suite("ShortcutRecorder Tests")
struct ShortcutRecorderTests {
    var recorder: ShortcutRecorder
    var delegate: MockShortcutRecorderDelegate
    
    class MockShortcutRecorderDelegate: ShortcutRecorderDelegate {
        var recordedShortcuts: [KeyboardShortcut] = []

        func shortcutRecorder(_ recorder: ShortcutRecorder, didRecordShortcut shortcut: KeyboardShortcut) {
            recordedShortcuts.append(shortcut)
        }
    }
    
    init() throws {
        recorder = ShortcutRecorder()
        delegate = MockShortcutRecorderDelegate()
        
        recorder.delegate = delegate
    }

    @Test("Recorder initializes correctly")
    func initializesCorrectly() {
        #expect(delegate.recordedShortcuts.isEmpty)
    }
    
    @Test("Recorder can start and stop recording")
    func startAndStopRecording() {
        recorder.startRecording()
        recorder.stopRecording()
        
        #expect(true)
    }
    
    @Test("Handle multiple calls to record shortcut gracefully")
    func recordShortcutMultipleTimes() {
        recorder.startRecording()
        recorder.startRecording()
        recorder.startRecording()
        
        #expect(true)
    }
    
    @Test("Handle multiple calls to stop recording shortcut gracefully")
    func stopRecordingShortcutMultipleTimes() {
        recorder.stopRecording()
        recorder.stopRecording()
        recorder.stopRecording()
        
        #expect(true)
    }
    
    @Test("Save shortcuts with at least a single modifier", arguments: existingModifierFixtures)
    func handleEventWithModifiers(_ testCase: ExistingModifierCase) {
        recorder.startRecording()
        
        recorder.handleRecordingEvent(testCase.event)
        
        print(delegate.recordedShortcuts)
        
        #expect(delegate.recordedShortcuts.count == 1)
        #expect(delegate.recordedShortcuts[0].keyCode == testCase.shortcut.keyCode)
        #expect(delegate.recordedShortcuts[0].description == testCase.description)
    }
    
    @Test("Ignore shortcuts without at least one modifier", arguments: missingModifierFixtures)
    func ignoreEventWithoutModifiers(_ testCase: MissingModifierCase) {
        recorder.startRecording()
        
        recorder.handleRecordingEvent(testCase.event)
        
        #expect(delegate.recordedShortcuts.isEmpty)
    }
    
    @Test("Ignores events when not recording")
    func ignoreEventsWhenNotRecording() {
        recorder.handleRecordingEvent(defaultEvent)
        
        #expect(delegate.recordedShortcuts.isEmpty)
    }
    
    @Test("Stops recording after capturing shortcut")
    func stopAfterRecordingShortcut() {
        recorder.startRecording()

        recorder.handleRecordingEvent(defaultEvent)

        #expect(delegate.recordedShortcuts.count == 1)

        recorder.handleRecordingEvent(defaultEvent)

        #expect(delegate.recordedShortcuts.count == 1)
    }
}
