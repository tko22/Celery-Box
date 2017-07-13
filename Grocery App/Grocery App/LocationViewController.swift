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
        // Do any additional setup after loading the view, typically from a nib.
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "current_location_segue"){
            print ("current location segue")
            
        }
        else if (segue.identifier == "zip_code_segue"){
            print ("zip code segue")
        }
    }
    
    @IBAction func zip_code_primary_action(_ sender: UITextField) {
        print("zip code", zip_code.text ?? "default")
        
        //put zip_code in storage
        performSegue(withIdentifier: "zip_code_segue", sender: nil)

    }
    
    
    
}




