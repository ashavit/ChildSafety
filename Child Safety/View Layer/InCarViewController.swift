//
//  InCarViewController.swift
//  Child Safety
//
//  Created by Amir Shavit on 5/20/15.
//  Copyright (c) 2015 Amir & Geva. All rights reserved.
//

import UIKit
import AudioToolbox

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

    // MARK: - Notification Actions
    
    func beaconDeviceDetected()
    {
        if (!didAskAboutKids &&
            !shouldPauseAlert)
        {
            var kidsAlert = UIAlertController(title: "Car Beacon Detected",
                message: "Do you have kids with you?",
                preferredStyle: UIAlertControllerStyle.Alert)
            kidsAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler:
                { (alertAction) -> Void in
                    self.isKidInCar = false
            }))
            
            kidsAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Cancel, handler:
                { (alertAction) -> Void in
                    self.isKidInCar = true
            }))
            
            // Play sound
            AudioServicesPlaySystemSound(1005)

            showViewController(kidsAlert, sender: self)
            didAskAboutKids = true
        }
    }
    
    func beaconDeviceNotDetected()
    {
        println("not detected any more")
        if (isKidInCar)
        {
            displayAlert_LeftTheCar()
        }
    }
    
    // MARK: - Private Helpers

    var didAskAboutKids = false
    var didAskAboutLeftTheCar = false
    var shouldPauseAlert = false
    
    func displayAlert_LeftTheCar()
    {
        if (!didAskAboutLeftTheCar &&
            !shouldPauseAlert)
        {
            var outOfCarAlert = UIAlertController(title: "Car Beacon Not Detected",
                message: "Did you leave the car?",
                preferredStyle: UIAlertControllerStyle.Alert)
            outOfCarAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler:
                { (alertAction) -> Void in
                    self.didAskAboutLeftTheCar = false
                    self.pauseNotifications(15)
            }))
            
            outOfCarAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler:
                { (alertAction) -> Void in
                    self.displayAlert_DidYouRemoveTheKids()
            }))
            
            // Play sound
            AudioServicesPlaySystemSound(1005)
            
            showViewController(outOfCarAlert, sender: self)
            didAskAboutLeftTheCar = true
        }
    }
    
    func displayAlert_DidYouRemoveTheKids()
    {
        var kidsAlert = UIAlertController(title: "Did you take the kids with you?",
            message: nil,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        kidsAlert.addAction(UIAlertAction(title: "No",
            style: UIAlertActionStyle.Default,
            handler:
        { (alertAction) -> Void in
            
            // Play sound
            AudioServicesPlaySystemSound(1332)
            
            self.displayAlert_DidYouRemoveTheKids()
        }))
        
        kidsAlert.addAction(UIAlertAction(title: "Yes",
            style: UIAlertActionStyle.Destructive,
            handler:
        { (alertAction) -> Void in
            self.isKidInCar = false
            self.didAskAboutKids = false
            
            self.pauseNotifications(15)
        }))
        
        showViewController(kidsAlert, sender: self)
    }
    
    func pauseNotifications(time:NSTimeInterval)
    {
        shouldPauseAlert = true
        
        NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("resumeNotifications"), userInfo: nil, repeats: false)
    }
    
    func resumeNotifications()
    {
        shouldPauseAlert = false
    }
    @IBOutlet weak var textFiled: UITextField!
    @IBAction func pressed(sender: AnyObject)
    {
        if let num = textFiled.text.toInt()
        {
            AudioServicesPlaySystemSound(UInt32(num))
        }
    }
}
