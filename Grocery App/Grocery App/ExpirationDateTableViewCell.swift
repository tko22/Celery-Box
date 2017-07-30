//
//  ExpirationDateTableViewCell.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/29/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class ExpirationDateTableViewCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!

    static let reuseIdentifier = "DateCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
