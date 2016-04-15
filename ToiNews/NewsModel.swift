//
//  NewsModel.swift
//  News
//
//  Created by Ankush Kumar Singh on 19/08/15.
//  Copyright (c) 2015 Citi. All rights reserved.
//

import Foundation
import UIKit

class NewsModel :NSObject{
    var newImage :String?
    var newsItemId : String
    var headLine : String
    var dateLine : String
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")

    init(newImage : String?, newsItemId : String, headLine: String , dateLine: String) {
        self.newImage = newImage
        self.newsItemId = newsItemId
        self.headLine = headLine
        self.dateLine = dateLine
        
    }
    /*convenience init(newsItemId : String, headLine: String , dateLine: String){
        self.init(newImage :nil, newsItemId : newsItemId , headLine: headLine, dateLine: dateLine)
    }*/
}

