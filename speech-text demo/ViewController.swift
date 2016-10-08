//
//  ViewController.swift
//  speech-text demo
//
//  Created by Wang Weihan on 9/22/16.
//  Copyright © 2016 Wang Weihan. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIPickerViewDataSource,UIPickerViewDelegate {
    
    //var indexRow = -1;
    var languageChoose = ""
    var audioURL: URL?
    var recordingSession: AVAudioSession!
    
    var languageArray = ["ar-AR_BroadbandModel",
                 "en-UK_BroadbandModel",
                 "en-UK_NarrowbandModel",
                 "en-US_BroadbandModel",
                 "en-US_NarrowbandModel",
                 "es-ES_BroadbandModel",
                 "es-ES_NarrowbandModel",
                 "fr-FR_BroadbandModel",
                 "ja-JP_BroadbandModel",
                 "ja-JP_NarrowbandModel",
                 "pt-BR_BroadbandModel",
                 "pt-BR_NarrowbandModel",
                 "zh-CN_BroadbandModel",
                 "zh-CN_NarrowbandModel"]
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var transcribedLabel: UILabel!
    @IBOutlet weak var buttonRecord: UIButton!
    @IBOutlet weak var buttonPlay: UIButton!
    
    let speechtotAnalyzer = SpeechToTextAnalyzer()

    var audioRecorder:AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    let isRecorderAudioFile = false
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
                          AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            
        } catch {
            // failed to record!
        }
       
        //self.buttonPlay.isEnabled = false;
        // Do any additional setup after loading the view, typically from a nib.
    }
    func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        //audioURL = URL(fileURLWithPath: "/Users/wangweihan/Downloads/0001.flac")
        return documentsDirectory
        /*let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("sound.flac")
        return soundURL*/
    }
    
    @IBAction func doRecording(_ sender: AnyObject) {
        if sender.titleLabel!!.text == "Record" {
            /*let audioSession = AVAudioSession.sharedInstance()
            do {
                
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioRecorder = AVAudioRecorder(url: self.directoryURL()!,
                                                    settings: recordSettings)
                audioRecorder.prepareToRecord()
            } catch {
            }
            do {
                self.buttonRecord.setTitle("Stop", for: UIControlState())
                self.buttonPlay.isEnabled = false
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch {
            }*/
            audioURL = getDocumentsDirectory()?.appendingPathComponent("recording.wav")
            
            let settings : [String : Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey:8,
                AVLinearPCMIsFloatKey:false,
                AVLinearPCMIsBigEndianKey:false,
                AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue
                //AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                buttonRecord.setTitle("Stop", for: .normal)
            } catch {
                //finishRecording(success: false)
            }
            
        }else{
            audioRecorder.stop()
            //finishRecording(success: true)
            audioRecorder = nil
            speechtotAnalyzer.analyze(languageChoose: languageChoose, audioSource: audioURL!) {
                (data, error) in
                if let error = error {
                    print(error)
                } else if data != nil {
                    print("data was received")
                    //let dataString = String(data: data, encoding: .utf8)
                    self.transcribedLabel.text = self.speechtotAnalyzer.respondString
                }
            }

            let audioSession = AVAudioSession.sharedInstance()
            do {
                self.buttonRecord.setTitle("Record", for: UIControlState())
                //self.buttonPlay.isEnabled = true
                try audioSession.setActive(false)
                //the audiorecorder address assign to audioURL
                
            } catch {
            }
        }
    }
    
   /* func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        audioURL =  audioRecorder.url
        /*speechtotAnalyzer.analyze(languageChoose: languageChoose, audioSource: audioURL) {
            (data, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                print("data was received")
                let dataString = String(data: data, encoding: .utf8)
                self.transcribedLabel.text = self.speechtotAnalyzer.respondString
            }
        }*/
        
        if success {
            buttonRecord.setTitle("Tap to Re-record", for: .normal)
        } else {
            buttonRecord.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }*/
    
    
    /*@IBAction func doPlay(_ sender: AnyObject) {
        if !audioRecorder.isRecording {
            self.audioPlayer = try! AVAudioPlayer(contentsOf: audioURL!)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self
            self.audioPlayer.play()
        }
    }*/
   
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languageArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageArray.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        languageChoose = languageArray[row]
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

