//
//  MasterViewController.swift
//  NotAnotherOneTask
//
//  Created by Энди on 11.08.16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import GoogleMaps


extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)"
    }
}

class EventsViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet var tableOfEvents: UITableView!
    
    var detailViewController: CurrentEventViewController? = nil
    
    var eventsArray : [Event] = []
    var activity = UIActivityIndicatorView()
    
    let locationManager = CLLocationManager()
    var locationString = String()
    var radiusOfEvents = Int()
    
    var flagForDoubleUpdating = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.radiusOfEvents = 13
        loadingSettings()
        
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CurrentEventViewController
        }
    }
    
    func loadingSettings() {
        activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activity.center = self.view.center
        activity.hidesWhenStopped = true
        self.view.addSubview(activity)
        activity.startAnimating()
        
        tableOfEvents.delegate = self
        tableOfEvents.tableFooterView = UIView()
        
        //Location Manager code to fetch current location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func networkManagerCall() {
        let parser = NetworkManager()
        parser.jsonParser(locationString, radius: radiusOfEvents, completionBlock: { (eventsJP) -> Void in
            self.eventsArray = eventsJP
            self.activity.stopAnimating()
            self.tableOfEvents.reloadData()
            
        })
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = eventsArray[indexPath.row]
                let controller = segue.destinationViewController as! CurrentEventViewController
                controller.event = object
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: EventCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventCell
        
        let event = eventsArray[indexPath.row]
        
        cell.bandName.text = event.name
        cell.bandImage.image = UIImage(named: "music.png")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
}

//MARK: - Google Maps

extension EventsViewController {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            
            
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        if let loc = location {
            
            locationString = String(loc.coordinate.latitude) + "," + String(loc.coordinate.longitude)
        }
        
        self.locationManager.stopUpdatingLocation()
        
        if self.flagForDoubleUpdating {
            self.networkManagerCall()
            self.flagForDoubleUpdating = false
        }
    }
    
//    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print("\(error.debugDescription)")
//        let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//        self.presentViewController(alert, animated: true, completion: nil)
//        self.activity.stopAnimating()
//    }
}

