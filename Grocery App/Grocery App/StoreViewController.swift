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
class StoreViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var differentStoreButton: UIButton!
    @IBOutlet weak var goToMapView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeInfoTableView: UITableView!
    @IBOutlet weak var storeAddressLabel: UILabel!
    @IBOutlet weak var moneySavedLabel: UILabel!
    @IBOutlet weak var StoreTodaysHourLabel: UILabel!
    
    
    let domain = "http://192.168.0.102:8000"
    var store_locations = [[String:Any]]()

    var curr_store_info = [String : Any]()
    var listOfStoresFound = [Any]()
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var different_store_counter = 0
    
    
    //table variables
    var store_info_parts = ["Directions","Website","Call"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeNameLabel.font = UIFont(name:"Raleway", size: 25)
        StoreTodaysHourLabel.font = UIFont(name:"Raleway",size:12)
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.goToMaps(_:)))
        goToMapView.addGestureRecognizer(gesture)
        
        storeInfoTableView.dataSource = self
        storeInfoTableView.delegate = self
        storeInfoTableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
        storeInfoTableView.tableFooterView = UIView()
        differentStoreButton.layer.cornerRadius = 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.fetchList().count == 0{
            alert(error_msg: "Please add items to your shopping list first!")
        }
        self.different_store_counter = 0
        self.activityIndicator.startAnimating()
        displayStore()
    }
    func displayStore(){
        
        if (UserDefaults.standard.string(forKey: "location_type") == "zip_code"){
            //get zip_code location
            if UserDefaults.standard.string(forKey: "zip_code") != nil{
                let zipCode = UserDefaults.standard.string(forKey: "zip_code")
                UserLocation.sharedInstance.getZipCodeCoordinates(zip_code: zipCode!, completion: { (success, location) in
                    if success{
                        self.findStore(location: location)
                    }
                    else{
                         self.alert(error_msg: "Can't get zip code location")
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
            findStore(location: loc)
        }
        
    }
    func findStore(location:CLLocation){
        //get stores around location
        //check unliked_stores
        //add storeLocations to store_locations
        //http post reuqest to api
        self.getListOfStores(location: location, completion: { (success, storearry) in
            if success {
                self.store_locations = storearry
//                for x in self.store_locations {
//                    print(x["name"])
//                }
                self.getBestStore(stores: self.store_locations, list: self.fetchList(), completion: { (success, storeinfo) in
                    if success {
                        self.getStoreInfo(place_id:storeinfo["place_id"] as! String, completion: { (bool, more_info) in
                            if bool {
                                DispatchQueue.main.async(){
                                    self.storeNameLabel.text = more_info["name"] as? String
                                    self.storeAddressLabel.text = more_info["address"] as? String
                                    self.StoreTodaysHourLabel.text = more_info["hours"] as? String
                                    //change image view - get url domain.com/static/store_formatted_name.jpg
                                    self.curr_store_info["formatted_name"] = more_info["name"] as? String
                                    self.curr_store_info["address"] = more_info["address"] as! String
                                    self.curr_store_info["hours"] = more_info["hours"] as! String
                                    self.curr_store_info["website"] = more_info["website"] as! String
                                    self.curr_store_info["phone_number"] = more_info["phone_number"] as? String
                                    self.displayMap(lat: self.curr_store_info["lat"] as! Double, lng: self.curr_store_info["lng"] as! Double)
                                    self.showElements()
                                }
                            }
                            
                        })
                    
                    }
                    
                })
            }
        })
        
    }
    func getListOfStores(location: CLLocation,completion:@escaping (Bool,[[String:Any]]) -> Void){
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&rankby=distance&keyword=grocery+store&key=AIzaSyAIdmnnHPTv0i_-0GiZ8A2Tgn8gUfGNSXQ")!
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                    {
                        if json["status"] as? String == "OK"{
                            var array = [[String:Any]]()
                            //Implement your logic
                            let stores_results = json["results"] as! [[String:Any]]
                            for store in stores_results{
                                guard let name = store["name"] as? String else {
                                    print("missing name")
                                    return
                                }
                                guard let place_id = store["place_id"] as? String else {
                                    print("missing place id")
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
                            let msg = json["status"] as? String
                            self.alert(error_msg: msg! )
                        }
                    }
                }catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    func getBestStore(stores:[[String:Any]],list:[Int], completion:@escaping (Bool,[String:Any]) -> ()){

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
        let json: [String:Any] = ["list":list,"stores":stores,"distance_pref":distance_pref,"organic_pref":organic_pref]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        //create POST Request
        //CHANGE Info.plist for temprorary http connections
        let url = URL(string: "\(domain)/bestsuppliers/?format=json")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String:Any]
                    {
                        if json["status"] as! String == "failed"{
                            let msg = json["message"] as? String
                            self.alert(error_msg: msg!)
                            print("Server Error",json["message"] ?? "Server Error")
                        }
                        guard let stores_array = json["stores"] as? [Any] else {
                            print("cant get json[\"stores\"]")
                            return
                        }
                        self.listOfStoresFound = stores_array
                        self.curr_store_info = stores_array[0] as! [String : Any]
                        
                        //Implement your logic
                        //let stores_results = json["store"] as! [[String:Any]]
                        
                        completion(true,self.curr_store_info)
                    }
                }catch {
                    print("Json Parsing error",error)
                }
            }
        })
        task.resume()
    
    }
    func getStoreInfo(place_id:String,completion: @escaping(Bool,[String:Any]) -> ()){
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string:"https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place_id)&key=AIzaSyAIdmnnHPTv0i_-0GiZ8A2Tgn8gUfGNSXQ")
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
                                return
                            }
                            guard let address = result["formatted_address"] as? String else {
                                print("Can't get Address")
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
                            
                            guard let opening_hours = result["opening_hours"] as? [String:Any] else {
                                print("Can't get opening hours dict")
                                return
                            }
                            
                            guard let hours_array = opening_hours["weekday_text"] as? [String] else{
                                print("Can't get opening hours")
                                return
                            }
                            var dayOfWeekIndex = self.getDayOfWeek()! - 2
                            if dayOfWeekIndex < 0{
                                dayOfWeekIndex = 6
                            }
                            
                            array = ["address":address,"phone_number":phone_number,"name":name,"website":website,"hours":hours_array[dayOfWeekIndex]]
                            
                            completion(true,array)
                        }
                        else{
                            let msg = json["status"] as? String
                            self.alert(error_msg: msg! )
                        }
                    }
                }catch{
                    
                }
            }
        })
        task.resume()
        
    }
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
    func alert(error_msg:String){
        let alert = UIAlertController(title: "Alert", message: error_msg , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            self.dismiss(animated: true,completion:nil)
        }))
        self.present(alert, animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
    }
    func alertWithoutClosing(error_msg:String){
        let alert = UIAlertController(title: "Alert", message: error_msg , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
        self.dismiss(animated: true,completion:nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func displayMap(lat:Double,lng:Double){
        let initialLocation = CLLocation(latitude: lat, longitude: lng)
        let regionRadius: CLLocationDistance = 100
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                      regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        centerMapOnLocation(location: initialLocation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        mapView.addAnnotation(annotation)
    }
    // > button clicked
    @IBAction func goToMapsButtonAction(_ sender: UIButton) {
        print("button_maps")
        //go to google maps
        
        openMaps(name: self.curr_store_info["formatted_name"] as! String,coor: CLLocationCoordinate2D(latitude: self.curr_store_info["lat"] as! Double, longitude: self.curr_store_info["lng"] as! Double))
        goToMapView.alpha = 0.9
        UIView.animate(withDuration: 0.6, animations: {
            self.goToMapView.alpha = 1
        })
    }
    //entire view with address clicked
    func goToMaps(_ sender:UITapGestureRecognizer){
        print("map")
        //go to google maps with coordinates
        
        openMaps(name: self.curr_store_info["formatted_name"] as! String,coor: CLLocationCoordinate2D(latitude: self.curr_store_info["lat"] as! Double, longitude: self.curr_store_info["lng"] as! Double))

        goToMapView.alpha = 0.9
        UIView.animate(withDuration: 0.6, animations: {
            self.goToMapView.alpha = 1
        })
    }
    
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
    @IBAction func findDifferentStore(_ sender: UIButton) {
        //get self.listOfStoresFound
        self.different_store_counter = self.different_store_counter + 1
        if self.different_store_counter >= self.listOfStoresFound.count{
            self.alertWithoutClosing(error_msg: "No more stores are available")
        }
        else{
//            activityIndicatorView.isHidden = false
//            activityIndicator.startAnimating()
            self.curr_store_info = self.listOfStoresFound[self.different_store_counter] as! [String : Any]
            self.getStoreInfo(place_id: self.curr_store_info["place_id"] as! String, completion: { (bool, more_info) in
                if bool {

                    DispatchQueue.main.async(){
                        self.storeNameLabel.text = more_info["name"] as? String
                        self.storeAddressLabel.text = more_info["address"] as? String
                        self.StoreTodaysHourLabel.text = more_info["hours"] as? String
                        //change image view
                        self.curr_store_info["formatted_name"] = more_info["name"] as? String
                        self.curr_store_info["address"] = more_info["address"] as! String
                        self.curr_store_info["hours"] = more_info["hours"] as! String
                        self.curr_store_info["website"] = more_info["website"] as! String
                        self.curr_store_info["phone_number"] = more_info["phone_number"] as? String
                        self.displayMap(lat: self.curr_store_info["lat"] as! Double, lng: self.curr_store_info["lng"] as! Double)
//                        self.showElements()
                    }
                }
                
            })
        }
        
    }
    func showElements(){
        activityIndicatorView.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
    }
    func getDayOfWeek()->Int? {
        return Calendar.current.component(.weekday, from: Date())
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
            destVC.listOfItems = self.fetchList()
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "shop_list_segue" {
            if self.curr_store_info.count == 0 {
                return false
            }
        }
        return true
        
    }
    
    /*
     Store info Tableview
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store_info_parts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreTableViewCell.reuseIdentifier, for: indexPath) as? StoreTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        cell.storeInfoLabel?.text = store_info_parts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row)
        {
        case 0: //Directions
            print("Directions")
            openMaps(name: self.curr_store_info["name"] as! String, coor: CLLocationCoordinate2D(latitude: self.curr_store_info["lat"] as! Double, longitude: self.curr_store_info["lng"] as! Double))
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

    
}

