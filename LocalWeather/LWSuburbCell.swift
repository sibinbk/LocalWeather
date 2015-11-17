//
//  LWSuburbCell.swift
//  LocalWeather
//
//  Created by Sibin Baby on 17/11/2015.
//  Copyright © 2015 Sibin Baby. All rights reserved.
//

import UIKit

class LWSuburbCell: UITableViewCell {

  @IBOutlet weak var venueLabel: UILabel!
  @IBOutlet weak var countryLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var updateTimeLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
