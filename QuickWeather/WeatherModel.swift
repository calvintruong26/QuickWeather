//
//  CurrentWeatherModel.swift
//  QuickWeather
//
//  Created by Calvin Truong on 11/8/16.
//  Copyright © 2016 Calvin Truong. All rights reserved.
//

import Foundation

class WeatherModel {
    var placeName : String
    var degrees : Int
    var description : String
    var timestamp : String
    var icon : String

    
    init() {
        self.placeName = ""
        self.degrees = 0
        self.description = ""
        self.timestamp = ""
        self.icon = ""
    }
    
    init(placeName: String, degrees: Int, desc: String, timestamp: String, icon: String) {
        self.placeName = placeName
        self.degrees = degrees
        self.description = desc
        self.timestamp = timestamp
        self.icon = icon
    }
    
}
