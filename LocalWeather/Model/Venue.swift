//
//  Venue.swift
//  LocalWeather
//
//  Created by Sibin Baby on 18/11/2015.
//  Copyright © 2015 Sibin Baby. All rights reserved.
//

import Foundation
import CoreData


class Venue: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

  func stringForUpdateTime() -> String {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    if let date = updateTime {
      return dateFormatter.stringFromDate(date)
    } else {
      return "NA"
    }
  }
  
}
