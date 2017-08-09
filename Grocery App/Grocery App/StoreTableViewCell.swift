//
//  StoreTableViewCell.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/17/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class StoreTableViewCell: UITableViewCell {

    static let reuseIdentifier = "StoreMinInfoCell"
    
    @IBOutlet weak var storeInfoLabel: UILabel!
    
    @IBOutlet weak var contributeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
