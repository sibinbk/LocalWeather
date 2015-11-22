//
//  LWSuburbDetailsController.swift
//  LocalWeather
//
//  Created by Sibin Baby on 20/11/2015.
//  Copyright © 2015 Sibin Baby. All rights reserved.
//

import UIKit
import CoreData

class LWSuburbDetailsController: UIViewController {

  var venue: Venue?
  
  @IBOutlet weak var venueLabel: UILabel!
  @IBOutlet weak var countryLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var weatherConditionLabel: UILabel!
  @IBOutlet weak var feelsLikeLabel: UILabel!
  @IBOutlet weak var windLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  @IBOutlet weak var sportLabel: UILabel!
  @IBOutlet weak var weatherIcon: UIImageView!
  
    override func viewDidLoad() {
      super.viewDidLoad()

      if let venueName = venue!.venueName {
        venueLabel.text = venueName
      }
      
      if let country = venue!.country {
        countryLabel.text = country
      }
      
      if let temperature = venue!.temperature {
        temperatureLabel.text = ("\(temperature)\u{00b0}")
      } else {
        temperatureLabel.text = "NA"
      }
      
      if let weatherCondition = venue!.weatherCondition {
        weatherConditionLabel.text = weatherCondition
      } else {
        weatherConditionLabel.text = ""
      }
      
      if let feelsLike = venue!.feelsLike {
        feelsLikeLabel.text = ("Feels Like \(feelsLike)\u{00b0}")
      } else {
        feelsLikeLabel.text = "Feels Like \nNA"
      }

      if let wind = venue!.wind {
        windLabel.text = wind
      } else {
        windLabel.text = "NA"
      }

      if let humidity = venue!.humidity {
        humidityLabel.text = humidity
      } else {
        humidityLabel.text = "NA"
      }

      if let sport = venue!.sport {
        sportLabel.text = "Sport | \(sport)"
      } else {
        sportLabel.text = "Sport | NA"
      }
      
      // Sets weather icon and view color.
      if let weatherIconName = venue!.weatherIcon {
        self.weatherIcon.image = UIImage(named: weatherIconName)
        let colorString = venue!.colorStringForWeatherCondition(weatherIconName)
        view.backgroundColor = UIColor(colorCode: colorString, alpha: 1.0)
      }
  }
  
  @IBAction func dismissView(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

}
