//
//  Venue+CoreDataProperties.swift
//  LocalWeather
//
//  Created by Sibin Baby on 20/11/2015.
//  Copyright © 2015 Sibin Baby. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Venue {

    @NSManaged var country: String?
    @NSManaged var temperature: NSNumber?
    @NSManaged var updateTime: NSDate?
    @NSManaged var venueName: String?
    @NSManaged var weatherCondition: String?
    @NSManaged var weatherIcon: String?
    @NSManaged var wind: String?
    @NSManaged var humidity: String?
    @NSManaged var feelsLike: NSNumber?
    @NSManaged var sport: String?

}
