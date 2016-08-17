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

class MasterViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet var tableOfEvents: UITableView!
    
    var detailViewController: DetailViewController? = nil

    var eventsArray : [Event] = []
    var activity = UIActivityIndicatorView()
    
    let locationManager = CLLocationManager()
    var locationString = String()
    
    var flagForDoubleUpdating = true


    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingSettings()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
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

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = eventsArray[indexPath.row]
                let controller = segue.destinationViewController as! DetailViewController
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
    
    
    // MARK: - Event process

    func processDataArray(dict: NSDictionary) {
        let event = Event()
        
        let dateString = dict.objectForKey("datetime") as! String
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let parsedDateTimeString = formatter.dateFromString(dateString) {
            event.datetime = parsedDateTimeString
        } else {
            print("Could not parse date")
        }
        
        let artists = dict.objectForKey("artists")
        for artists: NSDictionary in artists as! [[String: AnyObject]] {
            event.name = artists.objectForKey("name") as! String
            if let id = artists.objectForKey("mbid") as? String {
                event.mbid = id
            }
        }
        
        if let venue = dict.objectForKey("venue") {
            event.longitude = venue.objectForKey("longitude") as! Float
            event.latitude = venue.objectForKey("latitude") as! Float
        }
        
        eventsArray.append(event)
        eventsArray.sortInPlace{$0.datetime.compare($1.datetime) == .OrderedAscending}


    }
    
    
    
    
    //MARK: - JSON Parse
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func jsonParser(location: String, radius: Int) {
        let urlPath: String = String(format: "http://api.bandsintown.com/events/search?api_version=2.0&location=%@&radius=%i&format=json&app_id=NotAnotherOneTest",location, radius)
        
        guard let endpoint = NSURL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]] else {
                    throw JSONError.ConversionFailed
                }
                for events: NSDictionary in json {
                    
                    self.processDataArray(events)
                    
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.activity.stopAnimating()
                    self.tableOfEvents.reloadData()
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            }.resume()
        
    }

}

    //MARK: - Google Map

extension MasterViewController {
    
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
            jsonParser(locationString, radius: 13)
            self.flagForDoubleUpdating = false
        }
    }
}

