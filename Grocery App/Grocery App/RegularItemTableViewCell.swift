//
//  RegularItemTableViewCell.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/25/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class RegularItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    static let reuseIdentifier = "RegularItemCell"
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.font = UIFont(name:"Raleway", size: 15)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
