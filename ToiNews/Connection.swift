//
//  Connection.swift
//  News
//
//  Created by Ankush Kumar Singh on 19/08/15.
//  Copyright (c) 2015 Citi. All rights reserved.
//

import Foundation
import UIKit

protocol FetchItemViewControllerDelegate {
    func controller(controller: Connection, didFetchItem: String)
}

class Connection : NSObject , NSURLConnectionDelegate, NSURLConnectionDataDelegate {

    override init() {
    }

    var delegate : FetchItemViewControllerDelegate?

    var conData = NSMutableData()
    var connection: NSURLConnection?

    var responseLocal:NSURLResponse?
    var request:NSMutableURLRequest?

    func fetchNews (url : NSURL){
        request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 15.0)

        connection = NSURLConnection(request: request!, delegate: self, startImmediately: true)!
        connection?.start()
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){

        //print("Response: %@",response, appendNewline: false)
        self.responseLocal = response


        let statusCode = (response as! NSHTTPURLResponse).statusCode

        if statusCode == 200 {
            //print("Proper Response", appendNewline: false)
            let respDict = (responseLocal as! NSHTTPURLResponse).allHeaderFields
            let lastmodifiedStoredInPlist:String = (respDict as NSDictionary).objectForKey("Last-Modified") as! String

        }
        else{
            connection.cancel()
        }


    }


    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        //print("did receive data ")
        conData.appendData(data)
    }

    func connectionDidFinishLoading(connection: NSURLConnection) {
        do {
            let json : AnyObject = try NSJSONSerialization.JSONObjectWithData(conData, options: [])
            if let jsonDictionary :NSDictionary = json as? NSDictionary {
                let news : NSArray = jsonDictionary.objectForKey("NewsItem") as! NSArray
                for (var i = 0; i < news.count ; i++ )
                {
                    if let new_obj = news[i] as? NSDictionary
                    {
                        let newsItemId = new_obj["NewsItemId"] as? String
                        let headLine = new_obj["HeadLine"] as? String
                        let newImage = new_obj["Image"] as? NSDictionary
                        let dateLine = new_obj["DateLine"] as? String
                        
                        var imgUrlStr : String? = nil
                        
                        if let imgUrl: AnyObject = newImage?.objectForKey("Thumb"){
                            imgUrlStr = imgUrl as? String
                        }
                        
                        NewsService.sharedInstance.TableData.append(NewsModel(newImage: imgUrlStr, newsItemId: newsItemId!, headLine: headLine!, dateLine: dateLine!))
                    }
                }
                if let delegate = self.delegate {
                    delegate.controller(self, didFetchItem: "yes")
                }
            }
        } catch let error as NSError {
            print("json error: \(error.localizedDescription)")
        }

    }

    func connection(connection: NSURLConnection, didFailWithError error: NSError){

    }

    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse?{
        let userInfo = cachedResponse.userInfo
        let data = cachedResponse.data
        return NSCachedURLResponse(response: cachedResponse.response, data: data, userInfo: userInfo, storagePolicy: NSURLCacheStoragePolicy.Allowed)
    }

}


