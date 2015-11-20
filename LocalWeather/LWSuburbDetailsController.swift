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
  
    override func viewDidLoad() {
        super.viewDidLoad()

      if let venueName = venue!.venueName {
        venueLabel.text = venueName
      }
      
      if let country = venue!.country {
        countryLabel.text = country
      }
      
      if let temperature = venue!.temperature {
        temperatureLabel.text = ("\(temperature) C")
      } else {
        temperatureLabel.text = "NA"
      }
      
      if let weatherCondition = venue!.weatherCondition {
        weatherConditionLabel.text = weatherCondition
      } else {
        weatherConditionLabel.text = "NA"
      }
      
    }
}
