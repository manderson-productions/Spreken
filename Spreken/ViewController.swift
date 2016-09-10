//
//  ViewController.swift
//  Spreken
//
//  Created by Mark Anderson on 9/10/16.
//  Copyright © 2016 manderson-productions. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var speechInput: SpeechInput!
    var speechOutput: SpeechOutput!

    @IBOutlet weak var recordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.recordButton.isEnabled = false

        let localeIdentifier = "en-US"
        self.speechInput = SpeechInput(locale: Locale(identifier: localeIdentifier))
        self.speechInput.authorize { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Authorized")
                    self.recordButton.isEnabled = true
                    break
                case .denied:
                    print("Authorized")
                    break
                case .notDetermined:
                    print("Authorized")
                    break
                case .restricted:
                    print("Authorized")
                    break
                }
            }
        }

        let voiceFilter = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "en-US" }
        if let voice = AVSpeechSynthesisVoice(language: voiceFilter[0].language) {
            self.speechOutput = SpeechOutput(voice: voice)
        } else {
            fatalError("Voice not found!")
        }
    }

    fileprivate func didRecognizeSpeech(bestGuess: String) {
        self.speechOutput.speak(string: bestGuess)
    }

    // MARK: IBActions

    @IBAction func beginRecording(_ sender: UIButton) {
        let result = self.speechInput.beginRecognition()
        if !result {
            print("Some problem occurred with recognition startup...")
        }
        self.speechInput.recognitionHandler = self.didRecognizeSpeech
    }

    @IBAction func endRecording(_ sender: UIButton) {
        self.speechInput.endRecognition()
    }
}

