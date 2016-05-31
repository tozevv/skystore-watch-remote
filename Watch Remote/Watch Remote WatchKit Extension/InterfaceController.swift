//
//  InterfaceController.swift
//  Watch Remote WatchKit Extension
//
//  Created by Vieira, Antonio (Technology) on 26/05/2016.
//  Copyright © 2016 Vieira, Antonio (Technology). All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, WCSessionDelegate {
    

    //@IBOutlet var displayImage: WKInterfaceImage!
    @IBOutlet var button: WKInterfaceButton!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    
    
    let healthStore = HKHealthStore()
    var awayDetection = false
    
    var workoutSession : HKWorkoutSession?
    let heartRateUnit = HKUnit(fromString: "count/min")
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    var session: WCSession!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    
        //titleLabel.setText("The Revenant")
        
        //displayImage.setImageNamed("assets/revenant.jpg")
        
    }

    override func willActivate() {
        setupWorkout()
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
   
    
    // =========================================================================
    // MARK: - Actions

    
    func sendCommand(cmd: String)
    {
        let msg = ["keypressed": cmd];

        session.sendMessage(msg, replyHandler: { (responses) -> Void in
            print("done")
        }) { (err) -> Void in
            print(err)
        }
    }
    
    func readConfig()
    {
        let msg = ["config": "config"];
        
        session.sendMessage(msg, replyHandler: { (responses) -> Void in
            self.threshold = responses["threshold"] as! Double
            self.samplesLast = responses["samples"] as! Int
            self.steps = responses["steps"] as! Int

        }) { (err) -> Void in
            print(err)
        }
    }

    
    @IBAction func play() {
        startAwayDetection()
        sendCommand("play")
    }
    

    @IBAction func pause() {
        readConfig()
        stopAwayDetection()
        sendCommand("play")
    }

    func sleep() {
        self.stopAwayDetection()
        sendCommand("volumedown")
    }
    
    func away() {
        self.stopAwayDetection()
        sendCommand("search")
    }

    
    
    // =========================================================================
    // MARK: - Sleep and Away Detection
    
    var threshold = 0.75
    var samplesLast = 5
    var steps = 20
    
    var heartSamples = [Double]()
    
    func detectAwayOrSleep()
    {
        if heartSamples.count < samplesLast * 2 {
            return // not enough data to make a decision
        }
        
        let heartAverage = heartSamples.reduce(0, combine: +) / Double(heartSamples.count)
        let lastSamples = heartSamples.suffix(samplesLast)
        let heartLastAverage = lastSamples.reduce(0, combine: +) / Double(lastSamples.count)
        
        
        if (heartLastAverage / heartAverage) <= threshold
        {
            sleep()
        }
        
    }
    
    func startAwayDetection() {
        if (!awayDetection) {
            heartSamples = [Double]()
            self.workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.CrossTraining, locationType: HKWorkoutSessionLocationType.Indoor)
            self.workoutSession?.delegate = self
            healthStore.startWorkoutSession(self.workoutSession!)
        }
        awayDetection = true
    }

    func stopAwayDetection()
    {
        if (awayDetection) {
            if let workout = self.workoutSession {
                healthStore.endWorkoutSession(workout)
            }
        }
        awayDetection = false
    }
    
    
    func setupWorkout() {
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            heartRateLabel.setText("not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
            displayNotAllowed()
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType, HKObjectType.workoutType())
            healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes) { (success, error) -> Void in
            if success == false {
                self.displayNotAllowed()
            }
        }
    }

    
    func displayNotAllowed() {
        heartRateLabel.setText("not allowed")
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        switch toState {
        case .Running:
            workoutDidStart(date)
        case .Ended:
            workoutDidEnd(date)
        default:
            heartRateLabel.setText("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        // Do nothing for now
        heartRateLabel.setText("Workout error: \(error.userInfo)")
    }
    
    func workoutDidStart(date : NSDate) {
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.executeQuery(query)
        } else {
            heartRateLabel.setText("cannot start")
        }
    }
    
    func workoutDidEnd(date : NSDate) {
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.stopQuery(query)
            heartRateLabel.setText("---")
        } else {
            heartRateLabel.setText("cannot stop")
        }
    }
    
    func createHeartRateStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor else {return}
            self.anchor = newAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.anchor = newAnchor!
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        dispatch_async(dispatch_get_main_queue()) {
          
            guard let sample = heartRateSamples.first else{return}
            let value = sample.quantity.doubleValueForUnit(self.heartRateUnit)
            let intValue = Int(value)
            self.heartSamples.append(value)
            
            self.heartRateLabel.setText( String(UInt16(intValue)))
            
            self.detectAwayOrSleep()
            // retrieve source from sample
            /*let name = sample.sourceRevision.source.name
            self.updateDeviceName(name)
            self.animateHeart()*/
            
        }
    }
    
   
}
