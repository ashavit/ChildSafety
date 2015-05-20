//
//  BeaconManager.swift
//  Child Safety
//
//  Created by Amir Shavit on 5/20/15.
//  Copyright (c) 2015 Amir & Geva. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class BeaconManager : NSObject, ESTBeaconManagerDelegate
{
    let kNotificationNameBeaconDetected = "kNotificationNameBeaconDetected"
    let kNotificationNameBeaconNotDetected = "kNotificationNameBeaconNotDetected"
    let beaconProximityId = "B47E6506-7FA7-4226-A2A8-5033E685F418"
    
    private let estimoteAppId = "childsafty"
    private let estimoteAppToken = "b333699cea6162f55836e4cab614aee4"
//    let beaconProximityId = "B9407F30-F5F8-466E-AFF9-25556B57FE6D" // Estimote default
    
    var estimoteBeaconManager: ESTBeaconManager!
    var beaconRegion: CLBeaconRegion?
    var closestBeacon: CLBeacon? {
        didSet {
            
        }
    }
    
    class var sharedInstance: BeaconManager
    {
        struct Static
        {
            static let instance = BeaconManager()
        }
        return Static.instance
    }
    
    override init()
    {
        super.init()
        
        initEstimoteCloud()
        initEstimoteBeaconManager()
        
        if beaconRegion == nil
        {
            beaconRegion = CLBeaconRegion(proximityUUID:NSUUID(UUIDString:beaconProximityId), identifier: "EstimoteSampleRegion")
        }
    }
    
    deinit
    {
        stopBeaconScanning()
    }
    
    /// MARK: - Public Methods
    
    func startBeaconScanning()
    {
        /*
        * Starts looking for Estimote beacons.
        * All callbacks will be delivered to beaconManager delegate.
        */
        let authStatus = ESTBeaconManager.authorizationStatus()
        switch authStatus
        {
        case .NotDetermined:
            CLLocationManager().requestAlwaysAuthorization()
            estimoteBeaconManager.requestAlwaysAuthorization()
            estimoteBeaconManager.startRangingBeaconsInRegion(beaconRegion)
            
        case .AuthorizedAlways:
            estimoteBeaconManager.startRangingBeaconsInRegion(beaconRegion)
        case .AuthorizedWhenInUse:
            estimoteBeaconManager.startRangingBeaconsInRegion(beaconRegion)
            
        case .Denied:
            UIAlertView(title:"Location Access Denied", message:"You have denied access to location services. Change this in app settings.", delegate:self, cancelButtonTitle: "OK").show()
            
        case .Restricted:
            UIAlertView(title:"Location Not Available", message:"You have no access to location services.", delegate:self, cancelButtonTitle: "OK").show()
        }
    }

    private func stopBeaconScanning()
    {
        if let region = beaconRegion
        {
            estimoteBeaconManager.stopRangingBeaconsInRegion(region)
        }
    }
    

    /// MARK: - Helpers
    
    private func initEstimoteCloud()
    {
        // APP ID and APP TOKEN are required to connect to your beacons and make Estimote API calls
//        ESTCloudManager.setupAppID(estimoteAppId, andAppToken: estimoteAppToken)
//        
//        // Estimote Analytics allows you to log activity related to monitoring mechanism.
//        // At the current stage it is possible to log all enter/exit events when monitoring
//        // Particular beacons (Proximity UUID, Major, Minor values needs to be provided).
//        ESTCloudManager.enableMonitoringAnalytics(true);
//        ESTCloudManager.enableGPSPositioningForAnalytics(true);
    }
    
    private func initEstimoteBeaconManager()
    {
        estimoteBeaconManager = ESTBeaconManager()
        estimoteBeaconManager.delegate = self;
    }
    
    private func handleBeaconDetected(beacon:CLBeacon?)
    {
        if let detected = beacon
        {
            closestBeacon = detected
            
            if (detected.proximity == CLProximity.Near)
            {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationNameBeaconDetected, object: self)
            }
            else
            {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationNameBeaconNotDetected, object: self)
            }
        }
        else
        {
            closestBeacon = nil
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationNameBeaconNotDetected, object: self)
        }
    }
    
    
    // MARK: - ESTBeaconManager delegate
    
    func beaconManager(manager: AnyObject!, didStartMonitoringForRegion region: CLBeaconRegion!)
    {
        UIAlertView(title:"started monitoring", message:nil, delegate:self, cancelButtonTitle: "OK").show()
    }
    
    func beaconManager(manager: AnyObject!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!)
    {
        UIAlertView(title:"Ranging error", message:error.localizedDescription, delegate:self, cancelButtonTitle: "OK").show()
    }
    
    func beaconManager(manager: AnyObject!, monitoringDidFailForRegion region: CLBeaconRegion!, withError error: NSError!)
    {
        UIAlertView(title:"Monitoring error", message:error.localizedDescription, delegate:self, cancelButtonTitle: "OK").show()
    }

    func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!)
    {
        println("What to do with the \(beacons.count) beacons found?")
        if (beacons.count > 0)
        {
            handleBeaconDetected(beacons[0] as? CLBeacon)
        }
    }
}