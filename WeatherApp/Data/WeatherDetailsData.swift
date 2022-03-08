//
//  WeatherDetailsData.swift
//  WeatherApp
//
//  Created by Caleb Ngai on 3/7/22.
//

import Foundation
import RealmSwift

class WeatherDetailsData: Object {
    @objc dynamic var condition: String = ""
    @objc dynamic var cityName: String = ""
    @objc dynamic var temp: Double = 0.00
    @objc dynamic var feelsLike: Double = 0.00
    var parentCategory = LinkingObjects(fromType: WeatherRealmData.self, property: "details")
    
}



