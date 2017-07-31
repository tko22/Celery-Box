//
//  BarcodeReaderViewController.swift
//  Grocery App
//
//  Created by Timothy Ko on 7/26/17.
//  Copyright © 2017 tko. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class BarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var barcode = ""
    var location = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a session object.
        session = AVCaptureSession()
        
        // Set the captureDevice.
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Create input object.
        var videoInput: AVCaptureDeviceInput?
        
        
        DispatchQueue.main.async(){
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }
            let metadataOutput = AVCaptureMetadataOutput()
            // Add input to the session.
            if (self.session.canAddInput(videoInput)) {
                self.session.addInput(videoInput)
                
                self.session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code]
            }
            else {
                self.scanningNotPossible()
            }
            
            if (self.session.canAddOutput(metadataOutput)){
                
            }
            
            
            // Add previewLayer and have it show the video data
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session);
            let bounds = CGRect(x: 0, y: 72, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.previewLayer.frame = bounds
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            DispatchQueue.main.async {
                self.view.layer.addSublayer(self.previewLayer);
                let v = UIView.init(frame: CGRect(x:50, y: (self.view.window?.frame.height)! / 3.0, width: (self.view.window?.frame.width)!-100.0, height: 190))
                v.layer.borderWidth = 1.3
                v.layer.borderColor = UIColor.white.cgColor
                v.layer.cornerRadius = 8
                self.view.addSubview(v)
                // Begin the capture session.
                
                self.session.startRunning()
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        _ = self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if (session?.isRunning == false) {
            session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (session?.isRunning == true) {
            session.stopRunning()
        }
    }
    
    func scanningNotPossible() {
        // Let the user know that scanning isn't possible with the current device.
        let alert = UIAlertController(title: "Can't Scan.", message: "Let's try a device equipped with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        session = nil
        _ = navigationController?.popViewController(animated: true)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        print("capture")
        if let barcodeData = metadataObjects.first {
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject
            barcodeDetected(code: (barcodeReadable?.stringValue)!)
            // Vibrate the device to give the user some feedback.
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Avoid a very buzzy device.
            session.stopRunning()
        }
    }
    
    func barcodeDetected(code: String) {
        print("barcode",code)
        //Let the user know we've found something.
        let alert = UIAlertController(title: "Found a Barcode!", message: code, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.destructive, handler: { action in
            // Remove the spaces.
            var trimmedCode = code.trimmingCharacters(in: .whitespaces)
            if trimmedCode.characters.count > 12 {
                trimmedCode = String(trimmedCode.characters.dropFirst())
            }
            self.barcode = trimmedCode
            self.performSegue(withIdentifier: "addInfoSegue", sender: self)
            //all segue
        }))
        alert.addAction(UIAlertAction(title: "Cancel",style:UIAlertActionStyle.destructive,handler: { action in
            self.session.startRunning()
            alert.dismiss(animated: true,completion:nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addInfoSegue"{
            let destVC = segue.destination as! AddItemViewController
            destVC.barcode = self.barcode
        }
        else if segue.identifier == "addNewItem" {
            let destVC = segue.destination as! AddItemViewController
            destVC.barcode = ""
        }
    }
    

}
