//
//  AddItemTableViewCell.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/26/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoTextField: UITextField!
    static let reuseIdentifier = "AddItemInfoCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func textFieldPrimaryAction(_ sender: UITextField) {
        infoTextField.resignFirstResponder()
    }
    
}
