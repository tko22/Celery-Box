//
//  changeLocationViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/3/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class changeLocationViewController: UIViewController {
    
    @IBOutlet weak var zip_code_text: UITextField!
    
    @IBAction func changeToCurrentLocation(_ sender: UIButton) {
        let userDefault = UserDefaults.standard
        
        userDefault.set("current_location",forKey:"location_type")
        userDefault.synchronize()
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeToZipCode(_ sender: UITextField) {
        let userDefault = UserDefaults.standard
        userDefault.set(zip_code_text.text, forKey: "zip_code")
        userDefault.set("zip_code",forKey:"location_type")
        userDefault.synchronize()
        _ = navigationController?.popViewController(animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
