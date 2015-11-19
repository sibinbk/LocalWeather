//
//  LWPickerController.swift
//  LocalWeather
//
//  Created by Sibin Baby on 19/11/2015.
//  Copyright © 2015 Sibin Baby. All rights reserved.
//

import UIKit

protocol LWPickerControlDelegate: class {
  func didSelectPickerValueFilterKey(filterKey: String, value: String)
}

class LWPickerController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  var filterKey: String?
  var filteredListArray: [String]?
  
  weak var pickerDelegate: LWPickerControlDelegate?
  
  @IBOutlet weak var popUpView: UIView!
  @IBOutlet weak var pickerTableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      // Add transperancy to the view
      self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
      
      pickerTableView.delegate = self

    }

  // Mark:- Table view datasource.
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let filteredListArray = filteredListArray {
      return filteredListArray.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let ReuseIdentifierCell = "PickerCell"
    let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierCell, forIndexPath: indexPath)
    
    if let filteredListArray = filteredListArray {
      cell.textLabel?.text = filteredListArray[indexPath.row] as String
    }
    
    return cell
  }
  
  // Mark:- Table view delegate
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("Selected Row # \(indexPath.row)")
    if let pickerDelegate = pickerDelegate {
      pickerDelegate.didSelectPickerValueFilterKey(filterKey!, value: filteredListArray![indexPath.row])
    }
    
    dismissViewControllerAnimated(true, completion: nil)
  }
}
