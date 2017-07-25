//
//  LocationViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 6/27/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController {
    @IBOutlet weak var zip_code: UITextField!
    

    @IBOutlet weak var current_location_btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        current_location_btn.layer.cornerRadius = 4
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection OK")
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "Oops! Check if your internet connection is working" , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                self.dismiss(animated: true,completion:nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "current_location_segue"){
            print ("current location segue")
            let userDefault = UserDefaults.standard
            userDefault.set(zip_code.text, forKey: "zip_code")
            userDefault.set("current_location",forKey:"location_type")
            userDefault.synchronize()
            //print(userDefault.object(forKey: "location") as! String)

        }
        else if (segue.identifier == "zip_code_segue"){
            print ("zip code segue")
            
            let userDefault = UserDefaults.standard
            userDefault.set("zip_code",forKey:"location_type")
            userDefault.synchronize()
            
            //print(userDefault.object(forKey: "location") as! String)
            
        }
        UserDefaults.standard.set(true, forKey: "location_set")

    }
    
    @IBAction func zip_code_primary_action(_ sender: UITextField) {
        print("zip code", zip_code.text ?? "default")
        //put zip_code in storage
        performSegue(withIdentifier: "zip_code_segue", sender: nil)

    }
    
    
    
}




