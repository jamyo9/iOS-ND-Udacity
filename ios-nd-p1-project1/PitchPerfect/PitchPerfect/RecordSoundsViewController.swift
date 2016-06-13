//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Juan Alvarez on 9/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var startRecording: UIButton!
    @IBOutlet weak var stopRecording: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    
    enum RecordingState { case Recording, NotRecording }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("viewDidLoad Called")
        configureUI(.NotRecording)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("didReceiveMemoryWarning Called")
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear called")
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear called")
    }

    @IBAction func recordAudio(sender: AnyObject) {
        print("Recording...")
        
        configureUI(.Recording)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(sender: AnyObject) {
        print("Stop recording!")
        configureUI(.NotRecording)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("AVAudioRecorder finished saving recording")
        if (flag) {
            self.performSegueWithIdentifier("stopRecording", sender: audioRecorder.url)
        } else {
            print("Fail to record the sound")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue is being called")
        if (segue.identifier == "stopRecording") {
            let playSoundVC = segue.destinationViewController as! PlaySoundsViewController
            let recordAudioURL = sender as! NSURL
            playSoundVC.recordedAudioURL = recordAudioURL
        }
    }
    
    func configureUI(recordingState: RecordingState) {
        switch(recordingState) {
        case .Recording:
            setPlayButtonsEnabled(false)
            recordLabel.text = "Recording..."
        case .NotRecording:
            setPlayButtonsEnabled(true)
            recordLabel.text = "Tap to Record"
        }
    }
    
    func setPlayButtonsEnabled(enabled: Bool) {
        startRecording.enabled = enabled
        stopRecording.enabled = !enabled
    }
}

