//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by citiadmin on 4/8/16.
//  Copyright © 2016 raywenderlich. All rights reserved.
//

import Foundation
import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case New, Downloaded, Filtered, Failed
}

class PendingOperations {
    lazy var downloadsInProgress = [NSIndexPath:NSOperation]()
    lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var filtrationsInProgress = [NSIndexPath:NSOperation]()
    lazy var filtrationQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class ImageDownloader: NSOperation {
    let photoRecord: NewsModel
    init(photoRecord: NewsModel) {
        self.photoRecord = photoRecord
    }
    override func main() {
        if self.cancelled {
            return
        }
        let imageUrl = NSURL(string:self.photoRecord.newImage!)
        let imageData = NSData(contentsOfURL:imageUrl!)
        if self.cancelled {
            return
        }
        if imageData?.length > 0 {
            self.photoRecord.image = UIImage(data:imageData!)
            self.photoRecord.state = .Downloaded
        }
        else
        {
            self.photoRecord.state = .Failed
            self.photoRecord.image = UIImage(named: "Failed")
        }
    }
}

class ImageFiltration: NSOperation {
    let photoRecord: NewsModel
    
    init(photoRecord: NewsModel) {
        self.photoRecord = photoRecord
    }
    
    override func main () {
        if self.cancelled {
            return
        }
        
        if self.photoRecord.state != .Downloaded {
            return
        }
        
        if let filteredImage = self.applySepiaFilter(self.photoRecord.image!) {
            self.photoRecord.image = filteredImage
            self.photoRecord.state = .Filtered
        }
    }
    
    func applySepiaFilter(image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        
        if self.cancelled {
            return nil
        }
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter!.outputImage
        
        if self.cancelled {
            return nil
        }
        
        let outImage = context.createCGImage(outputImage!, fromRect: outputImage!.extent)
        let returnImage = UIImage(CGImage: outImage)
        return returnImage
    }
}