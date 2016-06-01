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
import CoreMotion

class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, WCSessionDelegate {
    
    @IBOutlet var sleepButton: WKInterfaceGroup!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var stepsLabel: WKInterfaceLabel!
    @IBOutlet var imagePackshot: WKInterfaceImage!
    
    let healthStore = HKHealthStore()
    var awayDetection = false
    var snoozeTimer = NSTimer()
    let snoozeInterval = 5.0
    
    var detectTimer = NSTimer()
    var detectInterval = 10.0
    
    var workoutSession : HKWorkoutSession?
    let heartRateUnit = HKUnit(fromString: "count/min")
    let stepsUnit = HKUnit.countUnit()
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    var anchor2 = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    
    var session: WCSession!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

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
    
    
    @IBAction func play() {
        startAwayDetection()
        sendCommand("play")
    }
    

    @IBAction func pause() {
        stopAwayDetection()
        sendCommand("play")
    }
    
    @IBAction func up() {
        sendCommand("up")
    }
    
    @IBAction func right() {
        sendCommand("right")
    }
    
    @IBAction func down() {
        sendCommand("down")
    }
    
    @IBAction func left() {
        sendCommand("left")
    }
    
    @IBAction func select() {
        sendCommand("select")
    }
    
    @IBAction func back() {
        sendCommand("back")
    }
    
    @IBAction func home() {
        sendCommand("home")
    }

    @IBAction func dismissSleepOrAway()
    {
        snoozeTimer.invalidate()
        sleepButton.setHidden(true)
    }
    
 
    @IBAction func myLibraryMenu() {
        pushControllerWithName("MyLibrary",
            context: [
                "segue": "pagebased", // hierarchical / pagebased
                "data":"Passed through hierarchical navigation"
            ]
        )
    }
    
   
    
    // =========================================================================
    // MARK: - Sleep and Away Detection
    
    var threshold = 0.75
    var samplesLast = 5
    var steps = 20
    
    var heartSamples = [Double]()
    var totalSteps = 0
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        print("data received \(message)")
        
        if let threshold = message["threshold"]  as? Double {
            self.threshold = threshold
        }
        if let samples = message["samples"]  as? Int {
            self.samplesLast = samples
        }
        if let steps = message["steps"]  as? Int {
            self.steps = steps
        }
    }
    
    func detectAwayOrSleep(timer: NSTimer!)
    {
        print("detecting state")
        
        if totalSteps > steps
        {
            print("triggered away")
            away()
            return
        }
        
        if samplesLast == 0
        {
            print("triggered sleep")
            sleep()
            return
        }
        
        if heartSamples.count < samplesLast * 2
        {
            return // not enough data to make a decision
        }
        
        let heartAverage = heartSamples.reduce(0, combine: +) / Double(heartSamples.count)
        let lastSamples = heartSamples.suffix(samplesLast)
        let heartLastAverage = lastSamples.reduce(0, combine: +) / Double(lastSamples.count)
        
        if (heartLastAverage / heartAverage) <= threshold
        {
            print("triggered sleep")
            sleep()
        }
    }
    
    func startAwayDetection() {
        if (!awayDetection) {
            heartSamples = [Double]()
            totalSteps = 0;
            
            self.workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Walking, locationType: HKWorkoutSessionLocationType.Indoor)
            self.workoutSession?.delegate = self
            healthStore.startWorkoutSession(self.workoutSession!)
            detectTimer =  NSTimer.scheduledTimerWithTimeInterval(detectInterval, target: self, selector: #selector(detectAwayOrSleep), userInfo: nil, repeats: true)
        }
        awayDetection = true
    }

    func stopAwayDetection()
    {
        if (awayDetection) {
            heartSamples = [Double]()
            totalSteps = 0;
            
            if let workout = self.workoutSession {
                healthStore.endWorkoutSession(workout)
            }
            detectTimer.invalidate()
        }
        awayDetection = false
    }
    
    func sleep() {
        
        
        WKInterfaceDevice.currentDevice().playHaptic(.Click)
        sleepButton.setHidden(false)
        
        snoozeTimer = NSTimer.scheduledTimerWithTimeInterval(snoozeInterval, target: self, selector: #selector(sleepTimeElapsed), userInfo: nil, repeats: false)
        
        
        self.startAwayDetection()
    }
    
    func away() {
        self.stopAwayDetection()
        
        WKInterfaceDevice.currentDevice().playHaptic(.Click)
        sleepButton.setHidden(false)
        
        snoozeTimer = NSTimer.scheduledTimerWithTimeInterval(snoozeInterval, target: self, selector: #selector(awayTimeElapsed), userInfo: nil, repeats: false)
        
    }
    
    func sleepTimeElapsed(timer: NSTimer!)
    {
        sleepButton.setHidden(true)
        self.stopAwayDetection()
        
        sendCommand("volumedown")
    }
    
    
    func awayTimeElapsed(timer: NSTimer!)
    {
        
        sleepButton.setHidden(true)
        self.stopAwayDetection()
        
        sendCommand("search")
    }

    
    func setupWorkout() {
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            heartRateLabel.setText("not available")
            return
        }
        
        guard let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
            displayNotAllowed()
            return
        }
        
        guard let stepsType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount) else {
            displayNotAllowed()
            return
        }
        
        
        let dataTypes = Set(arrayLiteral: heartRateType, stepsType, HKObjectType.workoutType())
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
        print("workoutDidStart")
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.executeQuery(query)
        } else {
            heartRateLabel.setText("cannot start")
        }
        
        if let query = createStepsStreamingQuery(date) {
            healthStore.executeQuery(query)
        } else {
            stepsLabel.setText("cannot start")
        }
    }
    
    func workoutDidEnd(date : NSDate) {
        print("workoutDidEnd")
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.stopQuery(query)
            heartRateLabel.setText("---")
        } else {
            heartRateLabel.setText("cannot stop")
        }
        
        if let query = createStepsStreamingQuery(date) {
            healthStore.stopQuery(query)
            stepsLabel.setText("---")
        } else {
            stepsLabel.setText("cannot stop")
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
    
    func createStepsStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount) else { return nil }
        
        let query = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: anchor2, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor else {return}
            self.anchor2 = newAnchor
            self.updateSteps(sampleObjects)
        }
        
        query.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.anchor2 = newAnchor!
            self.updateSteps(samples)
        }
        
        return query
    }
    
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        dispatch_async(dispatch_get_main_queue()) {
          
            guard let sample = heartRateSamples.first else{return}
            if(sample.quantity.isCompatibleWithUnit(self.heartRateUnit)) {
                let value = sample.quantity.doubleValueForUnit(self.heartRateUnit)
                let intValue = Int(value)
                self.heartSamples.append(value)
                self.heartRateLabel.setText( String(UInt16(intValue)))
            }
        }
    }
    
    func updateSteps(samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else {return}
        
        dispatch_async(dispatch_get_main_queue()) {
            
            guard let sample = samples.first else{return}
            let value = sample.quantity.doubleValueForUnit(self.stepsUnit)
            self.totalSteps += Int(value)
            self.stepsLabel.setText(String(self.totalSteps))
        }
    }
}