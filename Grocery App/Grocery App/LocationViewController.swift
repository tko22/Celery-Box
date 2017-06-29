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
        print ("got it")
        
        
        current_location_btn.layer.cornerRadius = 4
        // Do any additional setup after loading the view, typically from a nib.
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print ("yay")
        if (segue.identifier == "using_current_location"){
            print ("current location")
            
        }
        else if (segue.identifier == "using_zip_code"){
            print ("zip code")
            
        }
    }
    @IBAction func zip_code_primary_action(_ sender: Any) {
        print (zip_code.text ?? "default")
    }
    
    
    
}




