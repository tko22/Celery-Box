//
//  AddInfoViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/26/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBarStoreName: UINavigationItem!
    
    var barcode = String()
    var item_info_parts = ["name","brand","Full Price      $","size","barcode","On Sale"]
    var presetInfo = [String:String]() //name,price,size,barcode
    let domain = "http://192.168.0.102:8000"
    
    var edit_barcode = false
    var on_sale_item = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.presetInfo.removeAll()
        if self.item_info_parts.count > 6{
            self.item_info_parts.removeLast()
            self.item_info_parts.removeLast()
        }
        self.on_sale_item = false
        self.edit_barcode = false
        
        self.navBarStoreName.title = UserDefaults.standard.object(forKey: "gen_scanner_store") as? String
        self.activityIndicator.startAnimating()
        self.tableView.tableFooterView = UIView()
        if barcode == ""{
            self.edit_barcode = true
            self.hideActivityIndicator()
            self.tableView.reloadData()
        }
        else {
            self.getItemInfoFromNutritionix(code: self.barcode, completion: { (success,arr) in
                if success {
                    self.hideActivityIndicator()
                    self.presetInfo = arr
                    print(self.presetInfo)
                }
                else{
                    self.hideActivityIndicator()
                }
                self.tableView.reloadData()
            })
        }
    }
    
    func getItemInfoFromNutritionix(code: String, completion: @escaping (Bool,[String:String]) -> ()){
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "https://nutritionix-api.p.mashape.com/v1_1/item?upc=\(code)")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("pSWdppCF7HmshMAmBxkDIqlefo1Cp1gVGP8jsnc5AumquhrUIU", forHTTPHeaderField: "X-Mashape-Key")
        //TODO: move api key to safer location
        
        //Perform http request
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                DispatchQueue.main.async {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                        {
                            var array = [String:String]()
                            guard let name = json["item_name"] as? String else {
                                let error_code = json["error_code"] as! String
                                print("error",error_code)
                                completion(false,[:])
                                return
                            }
                            if let brand_name = json["brand_name"] as? String{
                                array["brand"] = brand_name
                            }
                            else{
                                array["brand"] = ""
                            }
                            array["name"] = name
                            completion(true,array)
                        }
                    }catch {
                        print("getListOfStores: error in JSONSerialization")
                    }
                }
            }
        })
        task.resume()

    }
    
    func addItemToDatabase(dict: [String:String], completion: (Bool,[String:String]) -> ()){
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dict)
        
        //create POST Request
        let url = URL(string: "\(domain)/fullprice/?format=json")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //TODO: CHANGE Info.plist for temprorary http connections
        
        // Insert json data to the request
        request.httpBody = jsonData
        
        //Start http request
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    //JSON recieved is an Array of Stores
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String:Any]
                    {
                        print(json)
                    }
                }catch {
                    print("getBestStore: Json Parsing error",error)
                }
            }
        })
        task.resume()

    }
    
    func switchTriggered(sender: AnyObject) {
        let s = sender as! UISwitch
        if s.tag == 2000 {
            // It's the onsale switch
            if s.isOn {
                self.item_info_parts.append("Discount Type")
                self.item_info_parts.append("Exp Date")
                self.on_sale_item = true
            }
            else if self.item_info_parts.count > 6{
                self.item_info_parts.removeLast()
                self.item_info_parts.removeLast()
                self.on_sale_item = false
            }
            self.tableView.reloadData()
        }
        else{
            print("ugh")
        }
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.barcode = ""
        self.dismiss(animated: true,completion:nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        var dict = [String:Any]()
        for i in 0 ... self.tableView.visibleCells.count - 1{
            if i != 5, i != 7{
                let cell = self.tableView.visibleCells[i] as! AddItemTableViewCell
                let text = cell.infoTextField.text!.trimmingCharacters(in: .whitespaces)
                if i != 4, text == "" {
                    self.alertWithoutClosing(error_msg: "Please fill in everything!")
                    return
                }
                else{
                    switch (i){
                    case 0: //name
                        dict["name"] = text
                    case 1:
                        dict["brand"] = text
                    case 2:
                        dict["full_price"] = text
                    case 3:
                        dict["size"] = text
                    case 4:
                        dict["barcode"] = self.barcode
                    case 6:
                        if self.on_sale_item{ //onsale
                            dict["on_sale"] = true
                            dict["discount_type"] = text
                        }
                        else { //not on sale
                            dict["on_sale"] = false
                            dict["discount_type"] = ""
                            dict["end_date"] = -1
                        }
                    default:
                        print("default save")
                    }
                }

            }
            else if i==7 {
                let cell = self.tableView.visibleCells[i] as! ExpirationDateTableViewCell
                dict["end_date"] = cell.datePicker.date.timeIntervalSince1970
            }
            else {
                print("on_sale_switch_cell")
            }
        }
        let s = UserDefaults.standard.object(forKey: "gen_scanner_store") as? String
        dict["supplier"] = s?.lowercased().replacingOccurrences(of: " ", with: "_")
        
        let coor = UserLocation.sharedInstance.getCurrentLocation().coordinate
        dict["location"] = "\(coor.latitude),\(coor.longitude)"
        
        alert(error_msg: "\(dict)")
    }
    
    func alert(error_msg:String){
        let alert = UIAlertController(title: "Alert", message: error_msg , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    //shows Alert Controller and stays in the same view
    func alertWithoutClosing(error_msg:String){
        let alert = UIAlertController(title: "Alert", message: error_msg , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func hideActivityIndicator(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.tableView.isHidden = false
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item_info_parts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        let row = indexPath.row
        
        if row == 5 { //Onsale switch
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseIdentifier, for: indexPath) as? SwitchTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            cell.label.text = item_info_parts[row]
            cell.tableSwitch.tag = 2000
            cell.tableSwitch.addTarget(self, action: #selector(switchTriggered(sender:)), for: .valueChanged)
            return cell
        }
        else if row == 7{ //expiration Date
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpirationDateTableViewCell.reuseIdentifier, for: indexPath) as? ExpirationDateTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            cell.datePicker.minimumDate = Date()
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddItemTableViewCell.reuseIdentifier, for: indexPath) as? AddItemTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            cell.infoLabel.text = item_info_parts[row]
            switch(row) {
            case 0: //name
                if self.presetInfo["name"] != nil {
                    cell.infoTextField.text = self.presetInfo["name"]
                }
                
            case 1: //brand
                if self.presetInfo["brand"] != nil {
                    cell.infoTextField.text = self.presetInfo["brand"]
                }
            case 2: // full price
                cell.infoTextField.placeholder = "ex: 4.99"
            case 3: //size
                cell.infoTextField.placeholder = "4oz or 1lb or 8oz"
            case 4: //barcode
                if self.edit_barcode{
                    cell.infoTextField.isUserInteractionEnabled = true
                }else {
                    cell.infoTextField.isUserInteractionEnabled = false
                    cell.infoTextField.text = self.barcode
                }
            case 6:
                cell.infoTextField.adjustsFontSizeToFitWidth = true
                let attr = [NSFontAttributeName:UIFont(name: "Raleway",size: 12)]
                cell.infoTextField.attributedPlaceholder = NSAttributedString(string: "Buy one get one $1.00 off or $2.50 off", attributes: attr)
            default:
                print("default")
            }
            return cell
        }
        

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 7{
            return 173
        }
        else {
            return 44
        }
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */


}
