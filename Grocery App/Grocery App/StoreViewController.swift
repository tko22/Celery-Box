//
//  StoreViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 6/30/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Contacts
import Firebase
class StoreViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var storeInfoTableView: UITableView!
    
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let domain = "http://192.168.0.111:8000"
    
    /*
        Array of stores parsed from google maps api request
        Each element of the array -> Dictionary [String:Any]
        Each dictionary properties - distance,name,lng,lat,place_id
     */
    var store_locations = [[String:Any]]()
    
    /*
        Current Store Information
        initialized in findStore() in the closure of getBestStore()
        properties - lat,lng,name,hours,website,place_id,distance,address,formatted_name,phone_number,onsaleitem_set([[String:Any]])
     */
    var curr_store_info = [String : Any]()
    
    /*
        Array of Stores returned by our API /bestsuppliers/
        initialized in getBestStore()
        Each element of the array -> Dictionary [String:Any]
        Each dictionary properties - distance,lat,lng,name,place_id,onsaleitem_set
        onsaleitem_set ([String:Any]) properties - discount,end_date,id,image_url,item_type,name,num_items,sale_price,start_date,supplier
    */
    var listOfStoresFound = [Any]()
    
    //Counter that remembers how many times you clicked different store until view is closed
    var different_store_counter = 0
    
    //Table cell names
    var store_info_parts = ["Directions","Website","Call"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TableView stuff
        storeInfoTableView.dataSource = self
        storeInfoTableView.delegate = self
        storeInfoTableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
        storeInfoTableView.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-FindBestStore" as NSObject,
            AnalyticsParameterItemName: "FindBestStore" as NSObject,
            AnalyticsParameterContentType: "User looked for the best store according to his/her list" as NSObject
            ])
        //checks if there are any items in items in the shopping list
        if self.fetchList().count == 0{
            alert(error_msg: "Please add items to your shopping list first!")
        }
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        self.storeInfoTableView.isHidden = true
        startFindingStore()
    }
    
    
    /*
        gets the location according to User settings for Zip Code/Current Location
            - if successful -> calls self.findStore(CLLocation)
    */
    func startFindingStore(){
        print("Starting to find store")
        
        //clear everything 
        store_locations.removeAll()
        curr_store_info.removeAll()
        listOfStoresFound.removeAll()
        self.different_store_counter = 0
        
        if (UserDefaults.standard.string(forKey: "location_type") == "zip_code"){
            //get zip_code location
            if UserDefaults.standard.string(forKey: "zip_code") != nil{
                let zipCode = UserDefaults.standard.string(forKey: "zip_code")
                //Gets the coordinates for a specific Zip Code
                UserLocation.sharedInstance.getZipCodeCoordinates(zip_code: zipCode!, completion: { (success, location) in
                    if success{
                        self.findStore(location: location)
                    }
                    else{
                         self.alert(error_msg: "Can't get Zip code location")
                    }
                })
            }
            else{
                self.alert(error_msg: "Can't get location")
            }
        }
        else if (UserDefaults.standard.string(forKey: "location_type") == "current_location"){
            // get current location
            let loc = UserLocation.sharedInstance.getCurrentLocation()
            self.findStore(location: loc)
        }
        
    }
    /*
        Finds the best store and displays the information - this is the main chunk of proccessing to find the store
        Calls 3 functions: getListOfStores,getBestStore,getStoreInfo
        1. Gets list of stores around location using Google Maps API
        2. Gets the Best Store - array also includes the 2nd,3rd,... best stores - This calls /bestsuppliers/ API endpoint
        3. Gets store information using Google Maps API
    */
    func findStore(location:CLLocation){
        print("findStore()")
        
        //get stores around location
        self.getListOfStores(location: location, completion: { (success, storearry,page_token_key) in
            if success {
                if storearry.count == 0 {
                    self.alert(error_msg: "Sorry, Can't find any stores around you")
                    return
                }
                
                //Wait one second to get second page of store results from google maps api
                let when = DispatchTime.now() + 1 // change 1 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.getNextPageStores(location: location, page_token: page_token_key, arr: storearry, completion: {
                        (success,arry) in
                        if success{
                            self.store_locations = arry
                            
//                            for x in self.store_locations {
//                                print(x["name"])
//                            }
                            
                            //Calls /bestsuppliers/ from API to get an array of best stores
                            self.getBestStore(stores: self.store_locations, list: self.fetchList(), completion: { (success, storeinfo) in
                                if success {
                                    
                                    self.curr_store_info = storeinfo
                                    //Gets store information for the Best Store and displays the information
                                    self.getStoreInfo(place_id:storeinfo["place_id"] as! String, completion: { (bool, more_info) in
                                        if bool {
                                            DispatchQueue.main.async(){
                                                
                                                
                                                //TODO: change image view - get url domain.com/static/store_formatted_name.jpg
                                                
                                                //adds additional information into self.curr_store_info - formatted_name,address,hours,website,phone number
                                                self.curr_store_info["formatted_name"] = more_info["name"] as? String
                                                self.curr_store_info["address"] = more_info["address"] as! String
                                                self.curr_store_info["hours"] = more_info["hours"] as! String
                                                self.curr_store_info["website"] = more_info["website"] as! String
                                                self.curr_store_info["phone_number"] = more_info["phone_number"] as? String
                                                self.storeInfoTableView.reloadData()
                                                
                                                self.showElements()
                                                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                                                    AnalyticsParameterItemID: "id-FindBestStore_success" as NSObject,
                                                    AnalyticsParameterItemName: "FindBestStore_success" as NSObject,
                                                    AnalyticsParameterContentType: "Found best store and displayed successfully" as NSObject
                                                    ])
                                            }
                                        }
                                        else {
                                            self.alert(error_msg: "Sorry, there was getting information on the store. Please try again or Contact Us.")
                                        }
                                    })
                                }
                            })
                        }
                    })

                }
                
                
            }else{
                self.alert(error_msg: "Sorry, there was an error finding stores around you. Please try again or Contact Us.")
            }
        })
        
    }
    
    /*
        Gets List Of Stores around a location
        Only called by findStore()
        completion handler returns [[String:Any]] - see self.store_locations(set to equal what is returned) to see more information
    */
    func getListOfStores(location: CLLocation, completion:@escaping (Bool,[[String:Any]],String) -> Void){
        print("Getting list of stores")
        //Sets up Http Request
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&rankby=distance&keyword=grocery+store&key=AIzaSyAIdmnnHPTv0i_-0GiZ8A2Tgn8gUfGNSXQ")!
        //TODO: move api key to safer location
        
        //Perform http request
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                    {
                        var array = [[String:Any]]()
                        if json["status"] as? String == "OK"{
                            //Parsing logic for json given by Google Maps API
                            let stores_results = json["results"] as! [[String:Any]]
                            let reference = json["next_page_token"] as! String
                            for store in stores_results{
                                guard let name = store["name"] as? String else {
                                    print("missing name")
                                    completion(false,array,"")
                                    return
                                }
                                guard let place_id = store["place_id"] as? String else {
                                    print("missing place id")
                                    completion(false,array,"")
                                    return
                                }
                                
                                let geoJSON = store["geometry"] as! [String:Any]
                                let coordinates = geoJSON["location"] as! [String:Double]
                                let lat = coordinates["lat"]!
                                let lng = coordinates["lng"]!
                                let distance = CLLocation(latitude: lat, longitude: lng).distance(from: location)
                                
                                array.append(["name":name.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "\'", with: "").replacingOccurrences(of: "-", with: ""),"place_id":place_id,"lat":lat,"lng":lng,"distance":distance])
                                
                            }
                            completion(true,array,reference)
                        }
                        else{
                            //alert with google status error message
                            let msg = json["status"] as? String
                            self.alert(error_msg: msg! )
                            completion(false,[],"")
                        }
                    }
                }catch {
                    print("getListOfStores: error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    func getNextPageStores(location:CLLocation,page_token:String, arr:[[String:Any]], completion: @escaping (Bool,[[String:Any]]) ->()){
        print("Getting next page of stores")
        //Sets up Http Request
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=\(page_token)&key=AIzaSyAIdmnnHPTv0i_-0GiZ8A2Tgn8gUfGNSXQ")!
        
        //Perform http request
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                    {
                        var array = arr
                        if json["status"] as? String == "OK"{
                            //Parsing logic for json given by Google Maps API
                            let stores_results = json["results"] as! [[String:Any]]
                            for store in stores_results{
                                guard let name = store["name"] as? String else {
                                    print("missing name")
                                    completion(false,array)
                                    return
                                }
                                guard let place_id = store["place_id"] as? String else {
                                    print("missing place id")
                                    completion(false,array)
                                    return
                                }
                                
                                let geoJSON = store["geometry"] as! [String:Any]
                                let coordinates = geoJSON["location"] as! [String:Double]
                                let lat = coordinates["lat"]!
                                let lng = coordinates["lng"]!
                                
                                let distance = CLLocation(latitude: lat, longitude: lng).distance(from: location)
                                
                                array.append(["name":name.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "\'", with: "").replacingOccurrences(of: "-", with: ""),"place_id":place_id,"lat":lat,"lng":lng,"distance":distance])
                            }
                            completion(true,array)
                        }
                        else{
                            //alert with google status error message
                            completion(true,arr)
                        }
                    }
                }catch {
                    completion(true,arr)
                    print("getListOfStores: error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    /*
        Calls /bestsuppliers/ endpoint to get an array of the best store ordered starting with the best
        completion handler returns [String:Any] with properties: lat,lng,name,hours,website,place_id,distance
    */
    func getBestStore(stores:[[String:Any]],list:[Int], completion:@escaping (Bool,[String:Any]) -> ()){
        print("Finding Best Store")
        //Set up http request
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let distance_pref:Double
        let organic_pref: Double
        if (UserDefaults.standard.object(forKey: "distance_slider_value") != nil){
            distance_pref = UserDefaults.standard.object(forKey: "distance_slider_value") as! Double
        }else{
            distance_pref = 5.0
        }
        if (UserDefaults.standard.object(forKey: "organics_slider_value") != nil){
            organic_pref = UserDefaults.standard.object(forKey: "organics_slider_value") as! Double
        }else {
            organic_pref = 5.0
        }
        //create json of the data to pass to /bestsuppliers/
        let json: [String:Any] = ["list":list,"stores":stores,"distance_pref":distance_pref,"organic_pref":organic_pref]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        //create POST Request
        let url = URL(string: "\(domain)/bestsuppliers/?format=json")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //TODO:CHANGE Info.plist for temprorary http connections
        
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
                    //let dataString = String(describing: NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                    //JSON recieved is an Array of Stores
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String:Any]
                    {
                        //Parsing logic to json giving by /bestsuppliers/ -> check API for more information on the json recieved
                        if json["status"] as! String == "failed"{
                            let msg = json["message"] as? String
                            self.alert(error_msg: msg!)
                            print("Server Error",msg ?? "Server Error")
                        }
                        guard let stores_array = json["stores"] as? [Any] else {
                            print("cant get json[\"stores\"]")
                            return
                        }
                        self.listOfStoresFound = stores_array
                        
                        completion(true,stores_array[0] as! [String:Any])
                    }
                }catch {
                    print("getBestStore: Json Parsing error",error)
                }
            }
        })
        task.resume()
        
    }
    
    /*
        Gets Additional Store Information - address,phone_number,formatted name, website, hours for today
        Calls Google Maps API - uses the place_id of a store
    */
    func getStoreInfo(place_id:String,completion: @escaping(Bool,[String:Any]) -> ()){
        print("Getting Store Information")
        //Set up http request
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string:"https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place_id)&key=AIzaSyAIdmnnHPTv0i_-0GiZ8A2Tgn8gUfGNSXQ")
        
        //Start http request
        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                    {
                        if json["status"] as? String == "OK"{
                            var array = [String:Any]()
                            //Implement your logic
                            guard let result = json["result"] as? [String:Any] else {
                                self.alert(error_msg: "Can't Get store Information. Try Again!")
                                completion(false,[:])
                                return
                            }
                            guard let address = result["formatted_address"] as? String else {
                                print("Can't get address")
                                return
                            }
                            guard let phone_number = result["formatted_phone_number"] as? String else{
                                print("Can't get phone number")
                                return
                            }
                            guard let name = result["name"] as? String else {
                                print("Can't get name of store")
                                return
                            }
                            guard let website = result["website"] as? String else {
                                print("Can't get website")
                                return
                            }
                            
                            //Gets hours for today
                            guard let opening_hours = result["opening_hours"] as? [String:Any] else {
                                print("Can't get opening hours dict")
                                return
                            }
                            guard let hours_array = opening_hours["weekday_text"] as? [String] else{
                                print("Can't get opening hours")
                                return
                            }
                            //self.getDayOfWeek() -> Int 1-7 with Sunday as 1 | hours_array[] -> indexes 0-6 with Sunday as 6
                            var dayOfWeekIndex = self.getDayOfWeek()! - 2
                            if dayOfWeekIndex < 0{
                                dayOfWeekIndex = 6
                            }
                            
                            array = ["address":address,"phone_number":phone_number,"name":name,"website":website,"hours":hours_array[dayOfWeekIndex]]
                            
                            //TODO:Get whether the store is open or not
                            completion(true,array)
                        }
                        else{
                            //alerts with message given by Google Maps Api
                            let msg = json["status"] as? String
                            self.alert(error_msg: msg! )
                        }
                    }
                }catch{
                    print("getStoreInfo: JSON parsing error",error)
                }
            }
        })
        task.resume()
        
    }
    
    
    /*
        fetches items in grocery list 
        returns an array [Int] with Grocery Item Ids --- REMEMBER TO UPDATE items.txt whenever changes are made to ItemType table in API
    */
    func fetchList() -> [Int]{
        var results = [ItemTypes]()
        var arry = [Int]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemTypes")
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            results = try managedObjectContext.fetch(fetchRequest) as! [ItemTypes]
            if(results.count == 0){
                _ = navigationController?.popViewController(animated: true)
            }
            for item in results{
                arry.append(Int(item.id))
            }
        }catch{
            fatalError("yay")
        }
        return arry
    }
    
    //shows Alert Controller with error_msg and goes back to grocery list view
    func alert(error_msg:String){
        let alert = UIAlertController(title: "Alert", message: error_msg , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-ErrorFindBestStore" as NSObject,
            AnalyticsParameterItemName: "Error finding best store" as NSObject,
            AnalyticsParameterContentType: "\(error_msg)" as NSObject
            ])
    }
    //shows Alert Controller and stays in the same view
    func alertWithoutClosing(error_msg:String){
        let alert = UIAlertController(title: "Alert", message: error_msg , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in

        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //function that opens Apple Maps
    func openMaps(name:String,coor:CLLocationCoordinate2D){
        let regionRadius:CLLocationDistance = 400
        let regionSpan = MKCoordinateRegionMakeWithDistance(coor, regionRadius, regionRadius)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let address = [CNPostalAddressStreetKey:self.curr_store_info["address"] as! String]
        let placemark = MKPlacemark(coordinate:coor,addressDictionary: address)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }

    
    //Hides view that holds activity indicator
    func showElements(){
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        self.storeInfoTableView.isHidden = false
    }
    //gets Day of Week - called by getStoreInfo()
    func getDayOfWeek()->Int? {
        return Calendar.current.component(.weekday, from: Date())
    }
    
    //Action when find Different Store button is clicked - checks whether there are anymore stores left to go through
    func differentStoreAction(sender: UIButton){
        if sender.tag == 150{
            print("Different Store button clicked")
            //get self.listOfStoresFound
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-findDifferentStore" as NSObject,
                AnalyticsParameterItemName: "findDifferentStore" as NSObject,
                AnalyticsParameterContentType: "Switching \(String(describing: self.curr_store_info["name"]))" as NSObject
                ])
            self.different_store_counter = self.different_store_counter + 1
            if self.different_store_counter >= self.listOfStoresFound.count{
                self.alertWithoutClosing(error_msg: "No more stores are available")
            }
            else{
                //            activityIndicatorView.isHidden = false
                //            activityIndicator.startAnimating()
                
                //gets additional store information and displays it
                self.curr_store_info = self.listOfStoresFound[self.different_store_counter] as! [String : Any]
                self.getStoreInfo(place_id: self.curr_store_info["place_id"] as! String, completion: { (bool, more_info) in
                    if bool {
                        
                        DispatchQueue.main.async(){
                            
                            //TODO: change image view
                            
                            self.curr_store_info["formatted_name"] = more_info["name"] as? String
                            self.curr_store_info["address"] = more_info["address"] as! String
                            self.curr_store_info["hours"] = more_info["hours"] as! String
                            self.curr_store_info["website"] = more_info["website"] as! String
                            self.curr_store_info["phone_number"] = more_info["phone_number"] as? String
                            self.storeInfoTableView.reloadData()
                        }
                    }
                    
                })
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "shop_list_segue"{
            let destVC = segue.destination as! ShopListViewController
            if self.curr_store_info.count == 0{
                return
            }
            destVC.onsaleitem_set = self.curr_store_info["onsaleitem_set"] as! [[String:Any]]
            destVC.regularitem_set = self.fetchList()
        }
    }
    //checks if you there is any information on the store chosen - if not, segue doesn't activate
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "shop_list_segue" {
            if self.curr_store_info.count == 0 {
                return false
            }
        }
        return true
        
    }
    
    // MARK: Table View Setup
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if section == 1{
            return store_info_parts.count
        }
        else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        if indexPath.section == 0{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreInfoTableViewCell.reuseIdentifier, for: indexPath) as? StoreInfoTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            cell.configure(curr_store: self.curr_store_info)
            cell.differentStoreButton.addTarget(self, action: #selector(differentStoreAction(sender:)), for: .touchUpInside)
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreTableViewCell.reuseIdentifier, for: indexPath) as? StoreTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            if indexPath.section == 1{
                cell.storeInfoLabel?.text = store_info_parts[indexPath.row]
            }
            else{
                cell.storeInfoLabel?.isHidden = true
                cell.contributeLabel?.isHidden = false
            }
            return cell
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch (indexPath.row)
            {
            case 0: //Directions
                print("Directions")
                openMaps(name: self.curr_store_info["formatted_name"] as! String, coor: CLLocationCoordinate2D(latitude: self.curr_store_info["lat"] as! Double, longitude: self.curr_store_info["lng"] as! Double))
            case 1: //Website
                print("Website")
                let url = URL(string: self.curr_store_info["website"] as! String)
                UIApplication.shared.open(url!)
                
            case 2: //Phone
                print("Phone")
                let num = self.curr_store_info["phone_number"] as? String
                let regex = num?.replacingOccurrences(of: "\\(|\\)|-| ", with: "", options: .regularExpression)
                guard let number = URL(string: "tel://\(regex!)") else {
                    return
                }
                UIApplication.shared.open(number)
            default:
                print("default case")
            }

        }
        else if indexPath.section == 2{
            print("go to scanner")
            performSegue(withIdentifier: "goToScanner", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0{
            return 418
        }
        else {
            return 44
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1{
            return "Store Info"
        } else if section == 2{
            return " "
        }
        else{
            return nil
        }
    }

    
}

