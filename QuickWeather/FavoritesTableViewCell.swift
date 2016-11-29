//
//  FavoritesTableViewCell.swift
//  QuickWeather
//
//  Created by Calvin Truong on 11/28/16.
//  Copyright © 2016 Calvin Truong. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    var zip = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
