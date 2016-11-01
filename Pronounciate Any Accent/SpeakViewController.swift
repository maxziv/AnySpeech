//
//  FirstViewController.swift
//  Pronounciate Any Accent
//
//  Created by Maxwell Zhou on 6/27/16.
//  Copyright © 2016 Max. All rights reserved.
//

import UIKit
import Speech

class SpeakViewController: UIViewController, SFSpeechRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    private let audioEngine = AVAudioEngine()
    private var locales: [Locale]!
    private let defaultLocale = Locale(identifier: "en-US")
    
    @IBOutlet private weak var textView : UITextView!
    @IBOutlet private weak var recordBtn : UIButton!
    @IBOutlet private weak var picker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordBtn.isEnabled = false
        
        locales = SFSpeechRecognizer.supportedLocales().map({$0})
        picker.dataSource = self
        picker.delegate = self
        let index = NSArray(array: locales).index(of: defaultLocale)
        picker.selectRow(index, inComponent: 0, animated: false)
        
        recordBtn.layer.cornerRadius = 4
        recordBtn.layer.masksToBounds = false
        recordBtn.layer.shadowColor = UIColor.black.cgColor
        recordBtn.layer.shadowOpacity = 0.2
        recordBtn.layer.shadowRadius = 2
        recordBtn.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        textView.isEditable = false
        prepareRecognizer(locale: defaultLocale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordBtn.isEnabled = true
                    
                case .denied:
                    self.recordBtn.isEnabled = false
                    self.recordBtn.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordBtn.isEnabled = false
                    self.recordBtn.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordBtn.isEnabled = false
                    self.recordBtn.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func prepareRecognizer(locale: Locale) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)!
        speechRecognizer.delegate = self
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordBtn.isEnabled = true
                self.recordBtn.setTitle("Start Recording", for: [])
                if let result = result {
                    self.textView.text.append("\n");
                    for segment in result.transcriptions[0].segments {
                        let confidencePercentage: Float = 100 * segment.confidence
                        let confidencePercentageString = String(format: "%3.1f%%", confidencePercentage)
                        self.textView.text.append(segment.substring + ": " + confidencePercentageString + "\n")
                    }
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        textView.text = "(listening...)"
    }
    
    // =========================================================================
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locales.count
    }
    
    // =========================================================================
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locales[row].localizedString(forIdentifier: locales[row].identifier)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let locale = locales[row]
        prepareRecognizer(locale: locale)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 17)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        pickerLabel?.text = locales[row].localizedString(forIdentifier: locales[row].identifier)
        
        return pickerLabel!
    }
    
    // =========================================================================
    // MARK: - SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordBtn.isEnabled = true
            recordBtn.setTitle("Start Recording", for: [])
        } else {
            recordBtn.isEnabled = false
            recordBtn.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    // =========================================================================
    // MARK: - Actions

    @IBAction func didSelectStart(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordBtn.isEnabled = false
            recordBtn.setTitle("Stopping", for: .disabled)
        } else {
            try! startRecording()
            recordBtn.setTitle("Stop recording", for: [])
        }
    }
}

