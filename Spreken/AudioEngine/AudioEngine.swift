//
//  AudioEngine.swift
//  Spreken
//
//  Created by Mark Anderson on 9/10/16.
//  Copyright © 2016 manderson-productions. All rights reserved.
//

import Foundation
import AVFoundation

public enum AudioSessionCategory {
    case playback, record
}

final class AudioEngine {

    fileprivate let audioEngine = AVAudioEngine()

    static let sharedInstance = AudioEngine()

    deinit {
        self.audioEngine.stop()
    }
    
    public func installTap(_ block: @escaping AVAudioNodeTapBlock) {
        guard let inputNode = self.audioEngine.inputNode else { fatalError("Audio engine has no input node") }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: block)
    }

    public func removeTap() {
        self.audioEngine.inputNode?.removeTap(onBus: 0)
    }

    public func setup(category: AudioSessionCategory) {
        DispatchQueue.main.async {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(category == .playback ? AVAudioSessionCategoryPlayback : AVAudioSessionCategoryRecord)
                try audioSession.setMode(AVAudioSessionModeMeasurement)
                try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            } catch {
                fatalError("Error: Audio Session Inittialization error")
            }
        }
    }

    public func start() throws {
        self.audioEngine.prepare()
        try self.audioEngine.start()
    }

    public func pause() {
        self.audioEngine.pause()
    }

    public func stop() {
        self.audioEngine.stop()
        self.removeTap()
    }
}
