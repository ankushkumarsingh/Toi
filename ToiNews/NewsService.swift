//
//  NewsService.swift
//  News
//
//  Created by Ankush Kumar Singh on 19/08/15.
//  Copyright (c) 2015 Citi. All rights reserved.
//

import Foundation
import UIKit

class NewsService: NSObject {

    var URLCache = NSURLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "ImageDownloadCache")

    class var sharedInstance : NewsService {
        struct Singleton {
            static let instance = NewsService()
        }
        return Singleton.instance
    }

    private override init() {}

    var TableData:Array< NewsModel > = Array < NewsModel >()
    //var newsData =

}