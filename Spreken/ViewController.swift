//
//  ViewController.swift
//  Spreken
//
//  Created by Mark Anderson on 9/10/16.
//  Copyright © 2016 manderson-productions. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate static let kTodoCellIdentifier = "todoCellIdentifier"
    fileprivate var speechInput: SpeechInput!
    fileprivate var speechOutput: SpeechOutput!
    fileprivate var todos = [Todo]()

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

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
                    print("Denied")
                    break
                case .notDetermined:
                    print("Not Determined")
                    break
                case .restricted:
                    print("Restricted")
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

    // MARK: IBActions

    @IBAction func beginRecording(_ sender: UIButton) {
        let result = self.speechInput.beginRecognition()
        if !result {
            print("Some problem occurred with recognition startup...")
        }
        self.speechInput.recognitionHandler = { [weak self] bestGuess in
            guard let strongself = self else { return }
            strongself.speechOutput.speak(string: bestGuess)
            strongself.todos.insert(Todo(title: bestGuess, timestamp: Date()), at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            strongself.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    @IBAction func endRecording(_ sender: UIButton) {
        self.speechInput.endRecognition()
    }

    // MARK: UITableViewDelegate/Datasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.kTodoCellIdentifier, for: indexPath)
        let todo = todos[indexPath.row]
        cell.textLabel?.text = todo.title
        cell.detailTextLabel?.text = DateFormat.sharedInstance.stringFromDate(date: todo.timestamp)

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at: \(indexPath)")
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todos.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

