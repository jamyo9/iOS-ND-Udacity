//
//  MemeTableCell.swift
//  MemeMe
//
//  Created by Juan Alvarez on 17/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var memedImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var meme:Meme! {
        didSet {
            memedImage.image = meme.memedImage
            label.text = meme.topText + " - " + meme.bottomText
        }
    }
}

