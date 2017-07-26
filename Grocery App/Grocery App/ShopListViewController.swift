//
//  ShopListViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/19/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class ShopListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var listOfItems = [Int]()
    var onsaleitem_set = [[String:Any]]()
    var list_items = [Int:String]() // dictionary of item names with id as key
    let sectionNames = ["On Sale Items","Others"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for x in self.onsaleitem_set {
            self.listOfItems = self.listOfItems.filter {
                $0 != x["item_type"] as! Int
            }
        }
        list_items = fillItemListArry(fileName: "items")!
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadData()
        print(self.onsaleitem_set)
    }
    
    
    func fillItemListArry(fileName: String) -> [Int:String]? {
        let path = Bundle.main.path(forResource: fileName, ofType: "txt")
        var return_array = [Int:String]()
        do {
            let text = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let itemsarray = text.components(separatedBy: ",")
            for item in itemsarray{
                let arr = item.components(separatedBy: "^")
                return_array[Int(arr.first!)!]=arr[1].replacingOccurrences(of: "_", with: " ")
            }
            return(return_array)
        } catch _ as NSError {
            return nil
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     
    */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section){
        case 0:
            return onsaleitem_set.count
        case 1:
            return listOfItems.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        if indexPath.section == 0{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OnSaleItemTableViewCell.reuseIdentifier, for: indexPath) as? OnSaleItemTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            cell.nameLabel?.text = self.onsaleitem_set[indexPath.row]["name"] as? String
            
            guard let sale_price = self.onsaleitem_set[indexPath.row]["sale_price"] as? String else {
                return cell
            }
            guard let discount = self.onsaleitem_set[indexPath.row]["discount"] as? String else {
                return cell
            }
            cell.onSalePriceLabel?.text = "$\(sale_price) "
            guard let full_price: Float = Float(sale_price)! + Float(discount)! else {
                return cell
            }
            let attributeString:NSMutableAttributedString = NSMutableAttributedString(string: "$" + String(full_price))
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSRange(location: 0,length: attributeString.length))
            cell.fullPriceLabel?.attributedText = attributeString
            return cell
        }
        else if indexPath.section == 1{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RegularItemTableViewCell.reuseIdentifier, for: indexPath) as? RegularItemTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            cell.nameLabel?.text = list_items[self.listOfItems[indexPath.row]]
            return cell
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RegularItemTableViewCell.reuseIdentifier, for: indexPath) as? RegularItemTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            return cell
        }
        
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            cell.accessoryType = .none
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0{
            return 74.0
        }else if indexPath.section == 1{
            return 57.0
        }
        return 74
    }
    
    


    

    
}


