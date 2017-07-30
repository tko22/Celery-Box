//
//  SetStoreLocationViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/27/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit

class SetStoreLocationViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    
    let stores = ["Acme markets","Aldi","Costco","FoodMaxx","Food lion","Giant","Hannaford","Jewel osco","Kmart","Kroger","Lucky","Market street","Martins food","Pavillions","Randalls","Safeway","Schnucks","Stop and shop","Target","Trader joes","Tom thumb","United supermarkets","Vons","Walmart","Whole foods"]
    var store = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Picker
    
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stores.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stores[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.store = stores[row]
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToScanner"{
            UserDefaults.standard.set(self.store,forKey: "gen_scanner_store")
        }
    }
    

}
