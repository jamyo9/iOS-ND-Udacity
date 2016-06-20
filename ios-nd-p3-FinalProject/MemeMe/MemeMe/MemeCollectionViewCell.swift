//
//  MemeCollectionViewCell.swift
//  MemeMe
//
//  Created by Juan Alvarez on 17/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit

//Copided from Udacity forum
class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var memedImage: UIImageView!
    
    var meme:Meme! {
        didSet {
            memedImage.image = meme.memedImage
        }
    }
}
