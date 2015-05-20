//
//  InCarViewController.swift
//  Child Safety
//
//  Created by Amir Shavit on 5/20/15.
//  Copyright (c) 2015 Amir & Geva. All rights reserved.
//

import UIKit

class InCarViewController: UIViewController
{
    var isKidInCar = false
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let beaconManager = BeaconManager.sharedInstance
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("beaconDeviceDetected"),
            name:beaconManager.kNotificationNameBeaconDetected,
            object: beaconManager)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("beaconDeviceNotDetected"),
            name:beaconManager.kNotificationNameBeaconNotDetected,
            object: beaconManager)
        
        beaconManager.startBeaconScanning()
    }

    // MARK: - Private Helpers
    
    var didAskAboutKids = false
    func beaconDeviceDetected()
    {
        if (!didAskAboutKids)
        {
            var kidsAlert = UIAlertController(title: "Car Beacon Detected", message: "Do have kids with you?", preferredStyle: UIAlertControllerStyle.Alert)
            kidsAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler:
                { (alertAction) -> Void in
                    self.isKidInCar = false
            }))
            
            kidsAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler:
                { (alertAction) -> Void in
                    self.isKidInCar = true
            }))
            
            showViewController(kidsAlert, sender: self)
            didAskAboutKids = true
        }
    }
    
    func beaconDeviceNotDetected()
    {
        println("not detected any more")
    }
}
