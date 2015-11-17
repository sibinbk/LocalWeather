//
//  LWSuburbListController.swift
//  LocalWeather
//
//  Created by Sibin Baby on 16/11/2015.
//  Copyright © 2015 Sibin Baby. All rights reserved.
//

import UIKit
import CoreData

class LWSuburbListController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  let urlString = "https://dnu5embx6omws.cloudfront.net/venues/weather.json"
  let ReuseIdentifierCell = "SuburbCell"
  
  lazy var fetchedResultsController: NSFetchedResultsController = {
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context = appDelegate.managedObjectContext

    // Initialize Fetch Request.
    let fetchRequest = NSFetchRequest(entityName: "Venue")
    
    // Add Sort Descriptors
    let sortDescriptor = NSSortDescriptor(key: "venueName", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Initialize Fetched Results Controller.
    let fetchedResultsController = NSFetchedResultsController (fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    
    // Configure Fetched Results Controller
    fetchedResultsController.delegate = self
    
    return fetchedResultsController
  }()
  
  // MARK: - View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getWeatherData()
  }
  
  @IBAction func reloadWeatherData(sender: UIBarButtonItem) {
    print("Refresh button pressed")
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
      self.getWeatherData()
    }
  }
  
  func getWeatherData() {
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context = appDelegate.managedObjectContext
    
    let url = NSURL(string: self.urlString)
    let session = NSURLSession.sharedSession()
    
    let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data,response, error) -> Void in
      
      do {
        let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        
        guard let weatherData = jsonResult["data"] as? NSArray else {
          print("No data to load")
          return
        }

        // Deleting existing Core Data entries before reloading json data.
        self.deleteSavedItems()
        
        // Enumerate contents of the array and save to Core Data
        for dataItem in weatherData {
          let newItem = NSEntityDescription.insertNewObjectForEntityForName("Venue", inManagedObjectContext: context) as! Venue
          
          if let venueName = dataItem["_name"] as? String {
            newItem.venueName = venueName
          }
          
          if let country = dataItem["_country"] as? NSDictionary {
            if let countryName = country["_name"] as? String {
              newItem.country = countryName
            }
          }
          
          if let temperature = dataItem["_weatherTemp"] as? String {
            newItem.temperature = temperature
          }
          
          if let updateTime = dataItem["_weatherLastUpdated"] as? Double {
            newItem.updateTime = NSDate(timeIntervalSince1970: updateTime)
          }
        }
        
        do {
          try context.save()
        } catch {
          let saveError = error as NSError
          print("\(saveError), \(saveError.userInfo)")
          
          self.showAlertWithTitle("Warning", message: "Your to-do could not be saved.", cancelButtonTitle: "OK")
        }
        
        do {
          try self.fetchedResultsController.performFetch()
        } catch {
          let fetchError = error as NSError
          print("\(fetchError), \(fetchError.userInfo)")
        }
        
        dispatch_async(dispatch_get_main_queue()) {
          self.tableView.reloadData()
        }
        
      }
      catch {
        print("Error: \(error)")
      }
      
    })
    
    dataTask.resume()
  }
  
  // MARK:- Core Data batch delete
  func deleteSavedItems() {
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let context = appDel.managedObjectContext
    let coord = appDel.persistentStoreCoordinator
    
    let fetchRequest = NSFetchRequest(entityName: "Venue")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
      try coord.executeRequest(deleteRequest, withContext: context)
    } catch let error as NSError {
      print("Error :\(error)")
    }
  }
  
  // MARK:- Helper Methods
  private func showAlertWithTitle(title: String, message: String, cancelButtonTitle: String) {
    // Initialize Alert Controller
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    // Configure Alert Controller
    alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: nil))
    
    // Present Alert Controller
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Table view data source
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if let sections = fetchedResultsController.sections {
      return sections.count
    }
    
    return 0
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sections = fetchedResultsController.sections {
      let sectionInfo = sections[section]
      return sectionInfo.numberOfObjects
    }
    
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierCell, forIndexPath: indexPath) as! LWSuburbCell
    
    // Configure Table View Cell
    configureCell(cell, atIndexPath: indexPath)
    
    return cell
  }
  
  func configureCell(cell: LWSuburbCell, atIndexPath indexPath: NSIndexPath) {
    // Fetch Venue data
    let venue = fetchedResultsController.objectAtIndexPath(indexPath) as! Venue
    
    if let venueName = venue.venueName {
      cell.venueLabel.text = venueName
    }
    
    if let country = venue.country {
      cell.countryLabel.text = country
    }
    
    // Formatted update time string.
    cell.updateTimeLabel.text = venue.stringForUpdateTime()
    
    if let temperature = venue.temperature {
      cell.temperatureLabel.text = ("\(temperature) C")
    } else {
      cell.temperatureLabel.text = "NA"
    }
  }

  // MARK:- Fetched Results Controller Delegate Methods
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch (type) {
    case .Insert:
      if let indexPath = newIndexPath {
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      }
      break;
    case .Delete:
      if let indexPath = indexPath {
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      }
      break;
    case .Update:
      break;
    case .Move:
      if let indexPath = indexPath {
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      }
      
      if let newIndexPath = newIndexPath {
        tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
      }
      break;
    }
  }
  
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the specified item to be editable.
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
  // Return false if you do not want the item to be re-orderable.
  return true
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
