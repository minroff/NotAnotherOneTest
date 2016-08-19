//
//  DetailViewController.swift
//  NotAnotherOneTask
//
//  Created by Энди on 11.08.16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import GoogleMaps

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
                
            })
            
        }).resume()
    }}

class CurrentEventViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var bandImage: UIImageView!
    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var bandImageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var bandImageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var mapViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var mapViewTopConstraint: NSLayoutConstraint!
    
    var event = Event()
    var imageURL = String()
    
    var detailItem: AnyObject? {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewOrientation()
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureView() {
        parserCall()
        
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
        
        let viewHeight = self.view.frame.size.width - self.navigationController!.navigationBar.frame.size.height
        let viewWidth = self.view.frame.size.height
        
        landscapePortraitSwitch(toInterfaceOrientation, padding: padding, viewWidth: viewWidth, viewHeight: viewHeight)
    }
    
    func setupViewOrientation() {
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        let padding: CGFloat = 0.0
        
        let viewHeight = self.view.frame.size.height - self.navigationController!.navigationBar.frame.size.height
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
    
    func parserCall() {
        let parser = Parser()
        let str = event.name.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        parser.jsonParser(str!, completionBlock: { (imageURL) -> Void in
            self.imageURL = imageURL
            self.bandImage.imageFromServerURL(self.imageURL)
        })
    }
    
    
}



