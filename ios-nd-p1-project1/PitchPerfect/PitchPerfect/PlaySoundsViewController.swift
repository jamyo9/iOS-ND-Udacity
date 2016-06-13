//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Juan Alvarez on 10/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var recordedAudioURL: NSURL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: NSTimer!
        
    enum ButtonType: Int {
        case Slow = 0, Fast, Chipmunk, Vader, Echo, Reverb
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("PlaySoundsViewController.viewDidLoad")
        setupAudio()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("PlaySoundsViewController.didReceiveMemoryWarning")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("PlaySoundsViewController.viewWillAppear")
        configureUI(.NotPlaying)
        snailButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        chipmunkButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        rabbitButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        vaderButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        echoButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        reverbButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        stopButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            let recordedAudioURL = sender as! NSURL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    @IBAction func playSoundForButton(sender: UIButton) {
        print("Play Sound Button Pressed")
        
        switch (ButtonType(rawValue: sender.tag)!){
        case .Slow:
            playSound(rate: 0.5)
        case .Fast:
            playSound(rate: 1.5)
        case .Chipmunk:
            playSound(pitch: 1000)
        case .Vader:
            playSound(pitch: -1000)
        case .Echo:
            playSound(echo: true)
        case .Reverb:
            playSound(reverb: true)
        }
        configureUI(.Playing)
    }
    
    @IBAction func stopSoundPressed(sender: UIButton) {
        print("Stop Sound Button Pressed")
        stopAudio()
    }

}
