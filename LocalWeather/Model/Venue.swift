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
  
  // Returns color string  for each weather condition
  
  func colorStringForWeatherCondition(condition: String) -> String {
    var colorString: String
    
    switch condition {
    case "clear":
      // Orange
      colorString = "F39C12"
      break
    case "cloudy":
      // Belize Hole (Dark Blue)
      colorString = "2980B9"
      break
    case "partlycloudy":
      // Peter Rive (Light Blue)
      colorString = "3498DB"
      break
    case "mostlycloudy":
      // Dark blue Material color
      colorString = "01579B"
      break
    case "rain":
      // Light Gray
      colorString = "5C5470"
      break
    case "tstorms":
      // Dark gray
      colorString = "352F44"
      break
    case "snow":
      // Turquoise
      colorString = "1ABC9C"
      break
    case "fog":
      colorString = "7F8C8D"
      break
    case "hazy":
      colorString = "CD9D77"
      break
    default:
      // Wet Asphalt
      colorString = "34495E"
    }
    
    return colorString
  }
}
