//
//  SpeechInput.swift
//  Spreken
//
//  Created by Mark Anderson on 9/10/16.
//  Copyright © 2016 manderson-productions. All rights reserved.
//

import Foundation
import Speech

typealias AuthorizationStatus = SFSpeechRecognizerAuthorizationStatus

final class SpeechInput: NSObject, SFSpeechRecognizerDelegate {

    fileprivate let recognizer: SFSpeechRecognizer
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?

    public var recognitionHandler: ((_ bestGuess: String) -> Void)?

    init?(locale: Locale) {
        guard let recognizer = SFSpeechRecognizer(locale: locale) else {
            print("Init failed for speech recognition")
            return nil
        }

        self.recognizer = recognizer
        self.recognitionHandler = nil

        super.init()
        self.recognizer.delegate = self
    }

    public func authorize(handler: @escaping (AuthorizationStatus) -> Void) {
        SFSpeechRecognizer.requestAuthorization(handler)
    }

    public func beginRecognition() -> Bool {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else { return false }

        // Cancel the previous task if it's running.
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = self.recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }

        recognitionRequest.shouldReportPartialResults = false

        self.recognitionTask = self.recognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in

            var isFinal = false

            if let result = result {
                isFinal = result.isFinal
                if isFinal {
                    self?.recognitionHandler?(result.bestTranscription.formattedString)
                }
            }
            if error != nil || isFinal {
                AudioEngine.sharedInstance.removeTap()

                self?.recognitionRequest = nil
                self?.recognitionTask = nil
                print("Done recording")
            }
        }

        AudioEngine.sharedInstance.setup(category: .record)

        AudioEngine.sharedInstance.installTap({ [weak self] (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self?.recognitionRequest?.append(buffer)
        })

        do {
            try AudioEngine.sharedInstance.start()
        } catch {
            print("Error: Could not start the AudioEngine: \(error)")
            return false
        }
        return true
    }

    public func endRecognition() {
        self.recognitionRequest?.endAudio()
    }

    // MARK: SFSpeechRecognizer Delegate

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Speech recognizer is now \(available ? "available" : "unavailable")")
    }
}
