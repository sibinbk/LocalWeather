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
      
      // Set pop up views corner radius
      popUpView.layer.cornerRadius = 10.0
      // Add transperancy to the view
      view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.25)
      
      pickerTableView.delegate = self

    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    
    showPopUpWithAnimation()
  }

  // MARK: - Table view datasource.
  
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
    
    cell.separatorInset = UIEdgeInsetsZero
    
    if let filteredListArray = filteredListArray {
      cell.textLabel?.text = filteredListArray[indexPath.row] as String
    }
    
    return cell
  }
  
  // MARK: - Table view delegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("Selected Row # \(indexPath.row)")
    if let pickerDelegate = pickerDelegate {
      pickerDelegate.didSelectPickerValueFilterKey(filterKey!, value: filteredListArray![indexPath.row])
    }
    
    removePopUpWithAnimation()
  }

  @IBAction func dismissPopUp(sender: AnyObject) {
    removePopUpWithAnimation()
    }
  
  func showPopUpWithAnimation()
  {
    self.popUpView.transform = CGAffineTransformMakeScale(0.1, 0.1)
    self.popUpView.alpha = 0.0;
    UIView.animateWithDuration(0.3, animations: {
      self.popUpView.alpha = 1.0
      self.popUpView.transform = CGAffineTransformMakeScale(1.0, 1.0)
    });
  }
  
  func removePopUpWithAnimation()
  {
    UIView.animateWithDuration(0.3, animations: {
      self.popUpView.transform = CGAffineTransformMakeScale(0.1, 0.1)
      self.popUpView.alpha = 0.0;
      }, completion:{(finished : Bool)  in
        if (finished)
        {
          self.dismissViewControllerAnimated(true, completion: nil)
        }
    });
  }
}
