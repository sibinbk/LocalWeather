//
//  LWSuburbListController.swift
//  LocalWeather
//
//  Created by Sibin Baby on 16/11/2015.
//  Copyright © 2015 Sibin Baby. All rights reserved.
//

import UIKit
import CoreData
import SystemConfiguration

class LWSuburbListController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
  
  private let urlString = "https://dnu5embx6omws.cloudfront.net/venues/weather.json"
  private let ReuseIdentifierCell = "SuburbCell"
  
  var searchResults = [Venue]()
  var resultSearchController: UISearchController!
  var filteredListArray = [String]()
  
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
  
  // MARK: - Check Reachability
  
  func connectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
      SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }) else {
      return false
    }
    
    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
      return false
    }
    
    let isReachable = flags.contains(.Reachable)
    let needsConnection = flags.contains(.ConnectionRequired)
    return (isReachable && !needsConnection)
  }

  // MARK: - View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.resultSearchController = UISearchController(searchResultsController: nil)
    self.resultSearchController.searchResultsUpdater = self
    self.resultSearchController.dimsBackgroundDuringPresentation = false
    self.resultSearchController.searchBar.sizeToFit()
    self.tableView.tableHeaderView = self.resultSearchController.searchBar
    
    // Check connectivity before network call.
  
    if connectedToNetwork() {
      loadWeatherData(urlString)
    } else {
      dispatch_async(dispatch_get_main_queue()) {
        self.showAlertWithTitle("No Network Connectivity!", message: "Please check your internet connectivity", cancelButtonTitle: "OK")
      }
    }
  }
  
  deinit{
    if let superView = resultSearchController.view.superview
    {
      superView.removeFromSuperview()
    }
  }
  
  @IBAction func reloadWeatherData(sender: UIBarButtonItem) {
    print("Refresh button pressed")
    // Reload weather data
    
    if connectedToNetwork() {
      loadWeatherData(urlString)
    } else {
      dispatch_async(dispatch_get_main_queue()) {
        self.showAlertWithTitle("No Network Connectivity!", message: "Please check your internet connectivity", cancelButtonTitle: "OK")
      }
    }
  }
  
  @IBAction func sortList(sender: AnyObject) {
    let actionSheet = UIAlertController(title: "Sort List By", message: nil, preferredStyle: .ActionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Update Time", style: .Default, handler: { (action) -> Void in
      self.reloadSortedList(NSSortDescriptor(key: "updateTime", ascending: false))
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Temperature", style: .Default, handler: { (action) -> Void in
      self.reloadSortedList(NSSortDescriptor(key: "temperature", ascending: false))
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Venue Name", style: .Default, handler: { (action) -> Void in
      self.reloadSortedList(NSSortDescriptor(key: "venueName", ascending: true))
    }))
    
    presentViewController(actionSheet, animated: true, completion: nil)
  }
  
  @IBAction func filterList(sender: AnyObject) {
    let actionSheet = UIAlertController(title: "Filter List By", message: nil, preferredStyle: .ActionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Show All", style: .Default, handler: { (action) -> Void in
      self.reloadFullListWithSortedData()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Country", style: .Default, handler: { (action) -> Void in
      let filterKey = "country"
      if let result = self.filteredList(filterKey) {
        print(result) // Remove this line
        self.filteredListArray = result
        self.performSegueWithIdentifier("pickerSegue", sender: filterKey)
      }
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Weather Condition", style: .Default, handler: { (action) -> Void in
      let filterKey = "weatherCondition"
      if let result = self.filteredList(filterKey) {
        print(result) // Remove this line
        self.filteredListArray = result
        self.performSegueWithIdentifier("pickerSegue", sender: filterKey)      }
    }))
    
    presentViewController(actionSheet, animated: true, completion: nil)
  }
  
  func loadWeatherData(urlString: String) {
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context = appDelegate.managedObjectContext
    
    let url = NSURL(string: urlString)
    let session = NSURLSession.sharedSession()
    
    let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data,response, error) -> Void in
      
      do {
        let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        
        guard let weatherData = jsonResult["data"] as? NSArray else {
          dispatch_async(dispatch_get_main_queue()) {
            self.showAlertWithTitle("Attention!", message: "No Weather data to load", cancelButtonTitle: "OK")
          }
          return
        }

        // Deleting existing Core Data entries before reloading json data.
        self.deleteSavedItems()
        
        // Move contents of the array into Core Data
        self.storeWeatherInfoFromData(weatherData, intoContext: context)
        
        // Save data
        self.saveDataIntoContext(context)
        
        // Fetch saved data from store.
        self.fetchAllDataFromStore()
        
      } catch {
        print("Error: \(error)")
      }
      
    })
    
    dataTask.resume()
  }
  
  // MARK: - Core Data batch delete
  
  func deleteSavedItems() {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context = appDelegate.managedObjectContext
    let storeCoordinator = appDelegate.persistentStoreCoordinator
    
    let fetchRequest = NSFetchRequest(entityName: "Venue")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
      try storeCoordinator.executeRequest(deleteRequest, withContext: context)
    } catch let error as NSError {
      print("Error :\(error)")
    }
  }
  
  // Mark: - Enumerate method to store JSON data into Core Data
  
  func storeWeatherInfoFromData(data :NSArray, intoContext context: NSManagedObjectContext) {
    // Enumerate contents of the array
    for dataItem in data {
      let newItem = NSEntityDescription.insertNewObjectForEntityForName("Venue", inManagedObjectContext: context) as! Venue
      
      if let venueName = dataItem["_name"] as? String {
        newItem.venueName = venueName
      }
      
      if let country = dataItem["_country"] as? NSDictionary {
        if let countryName = country["_name"] as? String {
          newItem.country = countryName
        }
      }
      
      if let weatherCondition = dataItem["_weatherCondition"] as? String {
        newItem.weatherCondition = weatherCondition
      }
      
      if let weatherIcon = dataItem["_weatherConditionIcon"] as? String {
        newItem.weatherIcon = weatherIcon
      }
      
      if let temperature = dataItem["_weatherTemp"] as? String {
        newItem.temperature = Int(temperature)
      }
      
      if let updateTime = dataItem["_weatherLastUpdated"] as? Double {
        newItem.updateTime = NSDate(timeIntervalSince1970: updateTime)
      }
    }
  }
  
  // MARK: - Save data into Core Data
  
  func saveDataIntoContext(context: NSManagedObjectContext) {
    do {
      try context.save()
    } catch {
      let saveError = error as NSError
      dispatch_async(dispatch_get_main_queue()) {
        self.showAlertWithTitle("Warning!", message: "Error while saving data! Error : \(saveError), \(saveError.userInfo)", cancelButtonTitle: "OK")
      }
      return
    }
  }
  
  // MARK: - Fetch all data from store
  
  func fetchAllDataFromStore() {
    self.fetchedResultsController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "venueName", ascending: true)]
    fetchedResultsController.fetchRequest.predicate = nil
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Error while fetching venue list")
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
    }
  }
  
  // MARK: - Reload for sorting
  
  func reloadSortedList(sortDescriptor: NSSortDescriptor? = nil) {
    fetchedResultsController.fetchRequest.sortDescriptors = [sortDescriptor!]
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Error while fetching venue list")
    }
    
    tableView.reloadData()
  }
  
  // MARK: - Reload All items with sorting
  
  func reloadFullListWithSortedData() {
    fetchedResultsController.fetchRequest.predicate = nil
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Error while fetching venue list")
    }
    
    tableView.reloadData()
  }
  
  // MARK: - Search Results Update method
  
  func updateSearchResultsForSearchController(searchController: UISearchController)
  {
    self.searchResults.removeAll(keepCapacity: false)
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "Venue")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "venueName", ascending: true)]
    
    let searchPredicate = NSPredicate(format: "venueName CONTAINS[c] %@", searchController.searchBar.text!)
    fetchRequest.predicate = searchPredicate
    
    do {
      if let results = try context.executeFetchRequest(fetchRequest) as? [Venue] {
        searchResults = results
      }
    } catch {
      fatalError("Error while fetching venue list")
    }
    
    tableView.reloadData()
  }
  
  // MARK: - Filter method to get distinct values
  
  func filteredList(filterItem: String) -> [String]? {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context = appDelegate.managedObjectContext
    
    var expressionDescriptions = [AnyObject]()
    expressionDescriptions.append(filterItem)
    
    let fetchRequest = NSFetchRequest(entityName: "Venue")
    fetchRequest.propertiesToFetch = [filterItem]
    fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
    fetchRequest.returnsDistinctResults = true
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: filterItem, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "%K != %@", filterItem, "")
    fetchRequest.propertiesToFetch = expressionDescriptions
    
    var resultArray = [String]()
    
    do {
      if let filteredList = try context.executeFetchRequest(fetchRequest) as? [[String: AnyObject]] {
        for item in filteredList {
          if let result = item[filterItem] as? String {
            resultArray.append(result)
          }
        }
      }
    } catch {
      print("error")
    }
    
    return resultArray
  }
  
  // MARK: - Helper Methods
  
  private func showAlertWithTitle(title: String, message: String, cancelButtonTitle: String) {
    // Initialize Alert Controller
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    // Configure Alert Controller
    alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: { (action) -> Void in
    }))
    
    // Present Alert Controller
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if self.resultSearchController.active {
      return 1
    } else {
      if let sections = fetchedResultsController.sections {
        return sections.count
      }
    }
    return 0
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if self.resultSearchController.active {
      return self.searchResults.count
    } else {
      if let sections = fetchedResultsController.sections {
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
      }
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
    
    let venueInfo: Venue
    
    if self.resultSearchController.active {
      venueInfo = self.searchResults[indexPath.row]
    } else {
      venueInfo = fetchedResultsController.objectAtIndexPath(indexPath) as! Venue
    }
    
    if let venueName = venueInfo.venueName {
      cell.venueLabel.text = venueName
    }
    
    if let country = venueInfo.country {
      cell.countryLabel.text = country
    }
    
    // Formatted update time string.
    cell.updateTimeLabel.text = venueInfo.stringForUpdateTime()
    
    if let temperature = venueInfo.temperature {
      cell.temperatureLabel.text = ("\(temperature) C")
    } else {
      cell.temperatureLabel.text = "NA"
    }
  }

  // MARK: - Table view data source
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let venue: Venue
    
    if self.resultSearchController.active {
      venue = self.searchResults[indexPath.row]
    } else {
      venue = fetchedResultsController.objectAtIndexPath(indexPath) as! Venue
    }
    
    performSegueWithIdentifier("suburbDetailSegue", sender: venue)
  }
  
  // MARK: - Fetched Results Controller Delegate Methods
  
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
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "pickerSegue" {
      if let destination = segue.destinationViewController as? LWPickerController {
        destination.filterKey = sender as? String
        destination.filteredListArray = self.filteredListArray
        destination.pickerDelegate = self
      }
    }
    
    if segue.identifier == "suburbDetailSegue" {
      if let destination = segue.destinationViewController as? LWSuburbDetailsController {
        destination.venue = sender as? Venue
      }
    }
  }
}

extension LWSuburbListController: LWPickerControlDelegate {
  
  // MARK: - Picker delegate method
  
  func didSelectPickerValueFilterKey(filterKey: String, value: String) {
    print(value)
    fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K == %@", filterKey, value)
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Error while fetching venue list")
    }
    
    self.tableView.reloadData()
  }
}