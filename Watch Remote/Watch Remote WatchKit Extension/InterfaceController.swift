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
    
    var playing:Bool = false
    
    
    let healthStore = HKHealthStore()
    
    
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
        setupHeart()
        
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
    
    @IBAction func click() {
        playing = !playing
        updateState()
    }
    
    
    
    func updateState() {
        if playing {
            self.button.setTitle("Pause")
            
            let msg = ["key": "ping"];
            session.sendMessage(msg, replyHandler: { (responses) -> Void in
                print(responses)
            }) { (err) -> Void in
                print(err)
            }
            
            startWorkout()
            
        } else {
            self.button.setTitle("Play")
            if let workout = self.workoutSession {
                healthStore.endWorkoutSession(workout)
            }
        }
    }

    
    func setupHeart() {
        
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
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        // Do nothing for now
        NSLog("Workout error: \(error.userInfo)")
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
    

    
    func startWorkout() {
        self.workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.CrossTraining, locationType: HKWorkoutSessionLocationType.Indoor)
        self.workoutSession?.delegate = self
        healthStore.startWorkoutSession(self.workoutSession!)
    }
    
    func createHeartRateStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        // adding predicate will not work
        // let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: HKQueryOptions.None)
        
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
            self.heartRateLabel.setText(String(UInt16(value)))
            
            // retrieve source from sample
            /*let name = sample.sourceRevision.source.name
            self.updateDeviceName(name)
            self.animateHeart()*/
            
        }
    }
    
    
    // =========================================================================
    // MARK: - Private
    /*
    private func createStreamingQuery() -> HKQuery {
        let predicate = HKQuery.predicateForSamplesWithStartDate(NSDate(), endDate: nil, options: .None)
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples)
        }
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples)
        }
        
        return query
    }
    
    private func addSamples(samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        guard let quantity = samples.last?.quantity else { return }
        heartRateLabel.setText("\(quantity.doubleValueForUnit(heartRateUnit))")
    }*/
    
    

}
