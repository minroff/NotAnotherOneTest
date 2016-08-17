//
//  DetailViewController.swift
//  NotAnotherOneTask
//
//  Created by Энди on 11.08.16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController, CLLocationManagerDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate {
    
    @IBOutlet weak var bandImage: UIImageView!
    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var bandImageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var bandImageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var mapViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var mapViewTopConstraint: NSLayoutConstraint!
    
    var urlSession = NSURLSession()
    
    var event = Event()
    var imageURL = String()
    
    var detailItem: AnyObject? {
        didSet {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.urlSession = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        setupViewOrientation()
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureView() {
        let str = event.name.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        jsonParser(str!)
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(CLLocationDegrees(event.latitude), longitude: CLLocationDegrees(event.longitude), zoom: 15)
        let  position = CLLocationCoordinate2DMake(CLLocationDegrees(event.latitude), CLLocationDegrees(event.longitude))
        let marker = GMSMarker(position: position)
        marker.title = event.name
        marker.map = mapView
        mapView.camera = camera
    }
    
    //MARK: - Rotation settings
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let padding: CGFloat = 0.0
        
        let viewHeight = self.view.frame.size.width - self.navigationController!.navigationBar.frame.size.height*2
        let viewWidth = self.view.frame.size.height
        
        landscapePortraitSwitch(toInterfaceOrientation, padding: padding, viewWidth: viewWidth, viewHeight: viewHeight)
    }
    
    func setupViewOrientation() {
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        let padding: CGFloat = 0.0
        
        let viewHeight = self.view.frame.size.height - self.navigationController!.navigationBar.frame.size.height*2
        let viewWidth = self.view.frame.size.width
        
        landscapePortraitSwitch(interfaceOrientation, padding: padding, viewWidth: viewWidth, viewHeight: viewHeight)
    }
    
    func landscapePortraitSwitch(interfaceOrientation: UIInterfaceOrientation, padding: CGFloat,viewWidth: CGFloat, viewHeight: CGFloat) {
        // if landscape
        if UIInterfaceOrientationIsLandscape(interfaceOrientation) {
            bandImageViewBottomConstraint.constant = padding
            bandImageViewTrailingConstraint.constant = (viewWidth/2.0) + (padding/2.0)
            
            mapViewTopConstraint.constant = padding
            mapViewLeadingConstraint.constant = (viewWidth/2.0) + (padding/2.0)
            
        } else { // else portrait
            bandImageViewBottomConstraint.constant = (viewHeight/2.0) + (padding/2.0)
            bandImageViewTrailingConstraint.constant = padding
            
            mapViewTopConstraint.constant = (viewHeight/2.0) + (padding/2.0)
            mapViewLeadingConstraint.constant = padding
        }
    }
    
    
    
    //MARK: - JSON Parse
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func jsonParser(name: String) {
        let urlPath: String = String(format: "http://api.bandsintown.com/artists/%@.json?api_version=2.0&app_id=NotAnotherOneTest",name)
        guard let endpoint = NSURL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        let request = NSMutableURLRequest(URL:endpoint)
        urlSession.dataTaskWithRequest(request) { (data, response, error) in
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
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        print("Did receive data!")
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        print("Response!!")
    }
    
    
}



