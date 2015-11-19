//
//  LWPickerController.swift
//  LocalWeather
//
//  Created by Sibin Baby on 19/11/2015.
//  Copyright © 2015 Sibin Baby. All rights reserved.
//

import UIKit

class LWPickerController: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
    return 10
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let ReuseIdentifierCell = "PickerCell"
    let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierCell, forIndexPath: indexPath)
    
    cell.textLabel?.text = "Row # \(indexPath.row)"
    
    return cell
  }
  
  // Mark:- Table view delegate
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("Selected Row # \(indexPath.row)")
    
    dismissViewControllerAnimated(true, completion: nil)
  }
}
