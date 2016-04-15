//
//  NewsTableViewController.swift
//  News
//
//  Created by Ankush Kumar Singh on 19/08/15.
//  Copyright (c) 2015 Citi. All rights reserved.
//

import UIKit
import Foundation

class NewsTableViewController: UITableViewController , FetchItemViewControllerDelegate {

    let pendingOperations = PendingOperations()

    override func viewDidLoad() {
        super.viewDidLoad()

        ////"Aug 20, 2015, 11.33AM IST"
        let time = "Jun 08, 2015, 11:27AM"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd, yyyy, HH:mma"
        let date = formatter.dateFromString(time)
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        let newString = formatter.stringFromDate(date!)
        NSLog("the time %@", time)
        NSLog("the newString %@", newString)
        let newDate = formatter.dateFromString(newString)
        NSLog("the date %@", newDate!)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        let connect = Connection()
        connect.delegate = self
        connect.fetchNews(NSURL(string: "http://timesofindia.indiatimes.com/feeds/newsdefaultfeeds.cms?feedtype=sjson")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func controller(controller: Connection, didFetchItem: String){
        if didFetchItem == "yes" {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return NewsService.sharedInstance.TableData.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(140.0)
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if let _ : String =  NewsService.sharedInstance.TableData[indexPath.row].newImage{
           let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath) as! WithImageTableViewCell

            cell.headline.text = NewsService.sharedInstance.TableData[indexPath.row].headLine
            cell.headline.numberOfLines = 0

            let dateStr = NewsService.sharedInstance.TableData[indexPath.row].dateLine
            let date = dateStr.characters.split(",").map(String.init)
            cell.date.text = date.last
            
            if cell.accessoryView == nil {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
                cell.accessoryView = indicator
            }
            let indicator = cell.accessoryView as! UIActivityIndicatorView
            let photoDetails = NewsService.sharedInstance.TableData[indexPath.row]
            cell.newsImage.image = photoDetails.image
            
            //4
            switch (photoDetails.state){
            case .Filtered:
                indicator.stopAnimating()
            case .Failed:
                indicator.stopAnimating()
                cell.textLabel?.text = "Failed to load"
            case .New, .Downloaded:
                indicator.startAnimating()
                if (!tableView.dragging && !tableView.decelerating) {
                    self.startOperationsForPhotoRecord(photoDetails, indexPath: indexPath)
                }
            }
 
            return cell

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath) as! WithoutImageTableViewCell

            cell.headLine.text = NewsService.sharedInstance.TableData[indexPath.row].headLine
            cell.headLine.numberOfLines = 0

            let dateStr = NewsService.sharedInstance.TableData[indexPath.row].dateLine
            let dateWithIST = dateStr.characters.split(",").map(String.init)
            let date = dateWithIST.last?.characters.split(" ").map(String.init)
            cell.date.text = date!.first

            return cell

        }

    }

    func startOperationsForPhotoRecord(photoDetails: NewsModel, indexPath: NSIndexPath){
        switch (photoDetails.state) {
        case .New:
            startDownloadForRecord(photoDetails, indexPath: indexPath)
        case .Downloaded:
            startFiltrationForRecord(photoDetails, indexPath: indexPath)
        default:
            NSLog("do nothing")
        }
    }
    
    func startDownloadForRecord(photoDetails: NewsModel, indexPath: NSIndexPath){
        //1
        if let downloadOperation = pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        
        //2
        let downloader = ImageDownloader(photoRecord: photoDetails)
        //3
        downloader.completionBlock = {
            if downloader.cancelled {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            })
        }
        //4
        pendingOperations.downloadsInProgress[indexPath] = downloader
        //5
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startFiltrationForRecord(photoDetails: NewsModel, indexPath: NSIndexPath){
        if let filterOperation = pendingOperations.filtrationsInProgress[indexPath]{
            return
        }
        
        let filterer = ImageFiltration(photoRecord: photoDetails)
        filterer.completionBlock = {
            if filterer.cancelled {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.filtrationsInProgress.removeValueForKey(indexPath)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            })
        }
        pendingOperations.filtrationsInProgress[indexPath] = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
    }

    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //1
        suspendAllOperations()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // 3
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    func suspendAllOperations () {
        pendingOperations.downloadQueue.suspended = true
        pendingOperations.filtrationQueue.suspended = true
    }
    
    func resumeAllOperations () {
        pendingOperations.downloadQueue.suspended = false
        pendingOperations.filtrationQueue.suspended = false
    }
    
    func loadImagesForOnscreenCells () {
        if let pathsArray = tableView.indexPathsForVisibleRows {
            var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            allPendingOperations.unionInPlace(pendingOperations.filtrationsInProgress.keys)
            
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtractInPlace(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtractInPlace(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
                if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }
                pendingOperations.filtrationsInProgress.removeValueForKey(indexPath)
            }
            
            for indexPath in toBeStarted {
                let indexPath = indexPath as NSIndexPath
                let recordToProcess = NewsService.sharedInstance.TableData[indexPath.row]
                startOperationsForPhotoRecord(recordToProcess, indexPath: indexPath)
            }
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

