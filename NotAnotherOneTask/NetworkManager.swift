 //
 //  Parser.swift
 //  NotAnotherOneTask
 //
 //  Created by Энди on 19.08.16.
 //  Copyright © 2016 Andrew. All rights reserved.
 //
 
 import UIKit
 
 class NetworkManager: NSObject {
    
    var eventsArray : [Event] = []
    var imageURL = String()
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func jsonParser(location: String, radius: Int, completionBlock:(eventsJP: Array<Event>)-> ()) {
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
                    completionBlock(eventsJP: self.eventsArray)
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            }.resume()
        
    }
    
    func jsonParser(name: String, completionBlock:(imageURL: String)-> ()) {
        let urlPath: String = String(format: "http://api.bandsintown.com/artists/%@.json?api_version=2.0&app_id=NotAnotherOneTest",name)
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
                
                if let imageURL = json.objectForKey("image_url"){
                    self.imageURL = imageURL as! String
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionBlock(imageURL: self.imageURL)
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            }.resume()
    }
    
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
    
 }
