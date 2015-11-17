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

  func stringForDate() -> String {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    if let date = NSDate(timeIntervalSince1970: updateTime) {
      return dateFormatter.stringFromDate(date)
    } else {
      return ""
    }
  }
}
