//
//  GroceryListTableViewCell.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/10/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class GroceryListTableViewCell: UITableViewCell {
    
    // properties
    static let reuseIdentifier = "GroceryItemCell"
    
    // outlets
    @IBOutlet weak var itemNameLabel: UILabel!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
