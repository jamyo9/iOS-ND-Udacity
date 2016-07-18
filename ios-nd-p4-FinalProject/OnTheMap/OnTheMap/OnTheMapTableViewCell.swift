//
//  OnTheMapTableViewCell.swift
//  OnTheMap
//
//  Created by Juan Alvarez on 17/6/16.
//  Copyright © 2016 Juan Alvarez. All rights reserved.
//

import UIKit


//Copided from Udacity forum
class OnTheMapTableViewCell: UITableViewCell {
    
    
//    @IBOutlet weak var pointImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var position:Position! {
        didSet {
            label.text = position.firstName + " " + position.lastName
        }
    }
}

