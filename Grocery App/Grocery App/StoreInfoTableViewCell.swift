//
//  StoreInfoTableViewCell.swift
//  Grocery App
//
//  Created by Timothy Ko on 8/5/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class StoreInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var differentStoreButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var storeAddressLabel: UILabel!
    @IBOutlet weak var storeTodayHoursLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeLogoImageView: UIImageView!
    @IBOutlet weak var moneySavedLabel: UILabel!
    @IBOutlet weak var goToMapsView: UIView!
    var curr_store_info = [String:Any]()
    static let reuseIdentifier = "StoreInfoCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        differentStoreButton.layer.cornerRadius = 4
        storeNameLabel.font = UIFont(name:"Raleway", size: 25)
        storeTodayHoursLabel.font = UIFont(name:"Raleway",size:12)
        differentStoreButton.tag = 150
        //sets up gesture recognizer for the view that overlaps the map - opens map when clicked
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.goToMaps(_:)))
        goToMapsView.addGestureRecognizer(gesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(curr_store:[String:Any]){
        if !curr_store.isEmpty{
            self.curr_store_info = curr_store
            self.storeNameLabel.text = curr_store["formatted_name"] as? String
            self.storeAddressLabel.text = curr_store["address"] as? String
            self.storeTodayHoursLabel.text = curr_store["hours"] as? String
            self.storeLogoImageView.image = UIImage(named: curr_store["db_name"] as! String)
            
            //displays Map and hides view holding activity indicator showing the main view
            self.displayMap(lat: curr_store["lat"] as! Double, lng: curr_store["lng"] as! Double)
        }
        
    }
    
    //Displays map in View -- Does NOT open MAPS
    func displayMap(lat:Double,lng:Double){
        print("Displaying Map")
        //Set up Location
        let initialLocation = CLLocation(latitude: lat, longitude: lng)
        let regionRadius: CLLocationDistance = 450
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                      regionRadius * 2.0, regionRadius * 2.0)
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
        centerMapOnLocation(location: initialLocation)
        
        //Sets Marker on Map
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        mapView.addAnnotation(annotation)
    }
    
    //> button clicked -> Opens Maps
    @IBAction func goToMapsButtonAction(_ sender: UIButton) {
        if self.curr_store_info.isEmpty{
            print("current store info is empty")
            return
        }
        print("Button_maps clicked ")
        //go to google maps with coordinates
        self.openMaps(name: self.curr_store_info["formatted_name"] as! String,coor: CLLocationCoordinate2D(latitude: self.curr_store_info["lat"] as! Double, longitude: self.curr_store_info["lng"] as! Double))
        goToMapsView
            .alpha = 0.9
        UIView.animate(withDuration: 0.6, animations: {
            self.goToMapsView.alpha = 1
        })
    }

    //entire view with address clicked -> Opens Maps
    func goToMaps(_ sender:UITapGestureRecognizer){
        print("Address view clicked")
        if self.curr_store_info.isEmpty{
            print("current store info is empty")
            return
        }
        //go to google maps with coordinates
        self.openMaps(name: self.curr_store_info["formatted_name"] as! String,coor: CLLocationCoordinate2D(latitude: self.curr_store_info["lat"] as! Double, longitude: self.curr_store_info["lng"] as! Double))

        goToMapsView.alpha = 0.9
        UIView.animate(withDuration: 0.6, animations: {
            self.goToMapsView.alpha = 1
        })
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
}
