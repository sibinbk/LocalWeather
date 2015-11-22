//
//  Venue.swift
//  LocalWeather
//
//  Created by Sibin Baby on 18/11/2015.
//  Copyright © 2015 Sibin Baby. All rights reserved.
//

import Foundation
import CoreData

enum Icon: String {
  case Clear = "clear"
  case Cloudy = "cloudy"
  case PartlyCloudy = "partlycloudy"
  case MostlyCloudy = "mostlycloudy"
  case Rain = "rain"
  case ThunderStorm = "tstorms"
  case Snow = "snow"
  case Fog = "fog"
  case Haze = "hazy"
}

class Venue: NSManagedObject {


  // Converts NSDate to String

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

  // Retrieves weather condtion from  weather icon.
  
  func weatherConiditionFromIcon(icon :String) -> String {
    var weather: String
    
    switch icon {
    case "clear":
      weather = "Clear"
      break
    case "cloudy":
      weather = "Overcast"
      break
    case "partlycloudy":
      weather = "Partly Cloudy"
      break
    case "mostlycloudy":
      weather = "Mostly Cloudy"
      break
    case "rain":
      weather = "Rain"
      break
    case "tstorms":
      weather = "Thunderstorm"
      break
    case "snow":
      weather = "Snow"
      break
    case "fog":
      weather = "Fog"
      break
    case "hazy":
      weather = "Haze"
      break
    default:
      weather = "NA"
    }
    
    return weather
  }
}
