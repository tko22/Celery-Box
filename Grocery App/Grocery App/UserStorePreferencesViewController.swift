//
//  UserStorePreferencesViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/3/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class UserStorePreferencesViewController: UIViewController {
   
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var organicSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let distance_object = UserDefaults.standard.object(forKey: "distance_slider_value"){
            distanceSlider.value = distance_object as! Float
            print(distance_object as! Float)
        }
        else {
            distanceSlider.value = 5.0
        }
        
        if let organic_object = UserDefaults.standard.object(forKey: "organics_slider_value"){
            organicSlider.value = organic_object as! Float
        }
        else {
            organicSlider.value = 5.0
        }
        distanceSlider.isContinuous = false
        organicSlider.isContinuous = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func distanceValueChanged(_ sender: UISlider) {
        print("save to user defaults")
        UserDefaults.standard.set(distanceSlider.value, forKey: "distance_slider_value")
    }

    @IBAction func organicValueChanged(_ sender: UISlider) {
        print("save to user defaults")
        UserDefaults.standard.set(organicSlider.value, forKey: "organics_slider_value")
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
