//
//  GameResultViewController.swift
//  Rock Paper Scissors
//
//  Created by Juan Alvarez on 13/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

enum PossiblePlays: String {
    case Paper = "Paper", Rock = "Rock", Scissors = "Scissors"
    
    static func randomPlay() -> PossiblePlays {
        let shapes = ["Rock", "Paper", "Scissors"]
        let randomChoice = Int(arc4random_uniform(3))
        return PossiblePlays(rawValue: shapes[randomChoice])!
    }
}

class GameResultViewController: UIViewController {
    
    @IBOutlet private weak var resultImage: UIImageView!
    @IBOutlet private weak var resultLabel: UILabel!
    
    var userChoice: PossiblePlays!
    private let computerChoice: PossiblePlays = PossiblePlays.randomPlay()
    override func viewDidLoad() {
        super.viewDidLoad()
        displayResult()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func displayResult() {
        // Ideally, most of this would be handled by a model.
        var imageName: String
        var text: String
        let matchup = "\(userChoice.rawValue) vs. \(computerChoice.rawValue)"
        
        // Why is an exclamation point necessary? :)
        switch (userChoice!, computerChoice) {
        case let (user, computer) where user == computer:
            text = "\(matchup): it's a tie!"
            imageName = "tie"
        case (.Rock, .Scissors), (.Paper, .Rock), (.Scissors, .Paper):
            text = "You win with \(matchup)!"
            imageName = "\(userChoice.rawValue)-\(computerChoice.rawValue)"
        default:
            text = "You lose with \(matchup) :(."
            imageName = "\(computerChoice.rawValue)-\(userChoice.rawValue)"
        }
        
        imageName = imageName.lowercaseString
        let img = UIImage(named: imageName)
        resultImage.image = img
        resultLabel.text = text
    }
    
    @IBAction func playAgain() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PlayGameViewController") as! PlayGameViewController
        presentViewController(vc, animated: true, completion: nil)
    }
}
