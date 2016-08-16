//
//  DetailViewController.swift
//  NotAnotherOneTask
//
//  Created by Энди on 11.08.16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var bandImage: UIImageView!
    @IBOutlet var mapView: GMSMapView!
    var event = Event()
    var imageURL = String()

    
    var detailItem: AnyObject? {
        didSet {

        }
    }


    func configureView() {
        
        jsonParser(event.mbid)
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(CLLocationDegrees(event.latitude), longitude: CLLocationDegrees(event.longitude), zoom: 15)        
        let  position = CLLocationCoordinate2DMake(CLLocationDegrees(event.latitude), CLLocationDegrees(event.longitude))
        let marker = GMSMarker(position: position)
        marker.title = event.name
        marker.map = mapView
        
        
        mapView.camera = camera

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - JSON Parse
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func jsonParser(mbid: String) {
        let urlPath: String = String(format: "http://api.bandsintown.com/artists/mbid_%@.json?api_version=2.0&app_id=NotAnotherOneTest",mbid)
        
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
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary else {
                    throw JSONError.ConversionFailed
                }
                
                if let kek = json.objectForKey("image_url"){
                    self.imageURL = kek as! String
                }
                

                
                dispatch_async(dispatch_get_main_queue()) {
                    if let url = NSURL(string: self.imageURL) {
                        if let data = NSData(contentsOfURL: url) {
                            self.bandImage.image = UIImage(data: data)
                        }
                    }
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            }.resume()
        
    }
    
}



