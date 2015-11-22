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
  var filterValue = ""
  
  private var selectedIndex: Int!
  
  weak var pickerDelegate: LWPickerControlDelegate?
  
  @IBOutlet weak var popUpView: UIView!
  @IBOutlet weak var pickerTableView: UITableView!
  @IBOutlet weak var titleLabel: UILabel!
  
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
    
    // Set previous selected value index
    if let filteredListArray =  filteredListArray {
      if let index = filteredListArray.indexOf(filterValue) {
        selectedIndex = index
      }
    }
    
    // Set PopUp Picker title
    if let pickerTitle = filterKey {
      switch pickerTitle {
        case "country":
          titleLabel.text = "Country"
          break
        case "weatherCondition":
          titleLabel.text = "Weather"
          break
        default:
          titleLabel.text = ""
      }
    }
    
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
    
    if let filteredListArray = filteredListArray {
      cell.textLabel?.text = filteredListArray[indexPath.row] as String
      
      if filterValue == filteredListArray[indexPath.row] {
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
      } else {
        cell.accessoryType = UITableViewCellAccessoryType.None
      }
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
