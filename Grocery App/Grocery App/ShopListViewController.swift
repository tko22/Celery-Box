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
    var onsaleitem_set = [Any]()
    
    let sectionNames = ["On Sale Items"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for x in self.onsaleitem_set as! [[String:Any]]{
            self.listOfItems = self.listOfItems.filter {
                $0 != x["item_type"] as! Int
            }
        }
        print(self.listOfItems)
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
        
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
        switch (indexPath.section)
        {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OnSaleItemTableViewCell.reuseIdentifier, for: indexPath) as? OnSaleItemTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RegularItemTableViewCell.reuseIdentifier, for: indexPath) as? RegularItemTableViewCell else {
                fatalError("Unexpected Index Path")
            }
        }
        
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }


    

    
}


