//
//  ViewController.swift
//  Rock Paper Scissors
//
//  Created by Juan Alvarez on 13/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class PlayGameViewController: UIViewController {

    @IBAction private func playRock(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("GameResultViewController") as! GameResultViewController
        vc.userChoice = getUserShape(sender)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction private func playPaper(sender: UIButton) {
        performSegueWithIdentifier("play", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "play" {
            let vc = segue.destinationViewController as! GameResultViewController
            vc.userChoice = getUserShape(sender as! UIButton)
        }
    }
    
    private func getUserShape(sender: UIButton) -> PossiblePlays {
        let play = sender.titleForState(.Normal)!
        return PossiblePlays(rawValue: play)!
    }
}

