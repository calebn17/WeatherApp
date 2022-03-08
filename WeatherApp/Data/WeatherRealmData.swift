//
//  WeatherRealmData.swift
//  WeatherApp
//
//  Created by Caleb Ngai on 3/6/22.
//

import Foundation
import RealmSwift

class WeatherRealmData: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var temp: Double = 0.00
    @objc dynamic var condition: String = ""
    @objc dynamic var feelsLike: Double = 0.00
    let details = List<WeatherDetailsData>()
}
