//
//  Extensions.swift
//  ToiNews
//
//  Created by citiadmin on 4/15/16.
//  Copyright © 2016 Citi. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        let indidcator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        indidcator.startAnimating()
        self.addSubview(indidcator)
        indidcator.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if let url = NSURL(string: urlString) {
                let session = NSURLSession.sharedSession()
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "GET"
                request.cachePolicy = NSURLRequestCachePolicy.ReloadRevalidatingCacheData
                
                let task = session.dataTaskWithRequest(request) {
                    (
                    let data, let response, error) in
                    
                    guard let imageData:NSData = data, let _:NSURLResponse = response  where error == nil else {
                        print("error")
                        return
                    }
                    let image : UIImage = UIImage(data: imageData)!
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        indidcator.stopAnimating()
                        indidcator.removeFromSuperview()
                        self.image = image
                    })
                }
                task.resume()
            }
        })
    }
}


extension NSDate {
   // "Apr 15, 2016, 12.16AM IST"
    //2015-08-20 13:47:32 +0000
    convenience init(dateString: String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "MMM dd, yyyy, HH.mm a"
        dateStringFormatter.timeZone = NSTimeZone(name: "IST")
        let date = dateStringFormatter.dateFromString(dateString)
        
        self.init(timeInterval:0, sinceDate:date!)
    }
    
    func getDatePart() -> NSDate {
        //let formatter = NSDateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        //formatter.timeZone = NSTimeZone(name: "UTC")
        let dateReturn :NSDate = self
        //print("self \(self)")
        return dateReturn
    }
}

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}
