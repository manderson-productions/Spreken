//
//  SpeechOutput.swift
//  Spreken
//
//  Created by Mark Anderson on 9/10/16.
//  Copyright © 2016 manderson-productions. All rights reserved.
//

import Foundation
import AVFoundation

final class SpeechOutput: NSObject, AVSpeechSynthesizerDelegate {

    fileprivate let voice: AVSpeechSynthesisVoice
    fileprivate let synthesizer: AVSpeechSynthesizer

    init(voice: AVSpeechSynthesisVoice) {
        self.voice = voice
        self.synthesizer = AVSpeechSynthesizer()
        super.init()
        self.synthesizer.delegate = self
    }

    public func speak(string: String) {

        AudioEngine.sharedInstance.setup(category: .playback)

        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = self.voice

        self.synthesizer.speak(utterance)
    }

    // MARK: AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Didstart: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Didfinish: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("Didpause: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("Didcontinue: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("Didcancel: \(utterance.speechString)")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        print("Will speak range of speech string: \(utterance.speechString)")
    }
}
