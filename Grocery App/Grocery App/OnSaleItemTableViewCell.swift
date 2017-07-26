//
//  ShopListTableViewCell.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/19/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class OnSaleItemTableViewCell: UITableViewCell {

    @IBOutlet weak var fullPriceLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var onSalePriceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    static let reuseIdentifier = "OnSaleItemCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.font = UIFont(name:"Raleway", size: 21)
        onSalePriceLabel.font = UIFont(name:"Raleway-Bold", size: 17)
        fullPriceLabel.font = UIFont(name:"Raleway",size:12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
