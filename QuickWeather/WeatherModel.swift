//
//  CurrentWeatherModel.swift
//  QuickWeather
//
//  Created by Calvin Truong on 11/8/16.
//  Copyright © 2016 Calvin Truong. All rights reserved.
//

import Foundation

class WeatherModel {
    var zip : String
    var id: Int
    var placeName : String
    var degrees : Int
    var description : String
    var timestamp : String
    var icon : String
    var weatherId : Int

    
    init() {
        self.placeName = ""
        self.degrees = 0
        self.description = ""
        self.timestamp = ""
        self.icon = ""
        self.weatherId = 0
        self.zip = ""
        self.id = 0
    }
    
    init(placeName: String, degrees: Int, desc: String, timestamp: String, icon: String, weatherId: Int, zip: String, id: Int) {
        self.placeName = placeName
        self.degrees = degrees
        self.description = desc
        self.timestamp = timestamp
        self.icon = icon
        self.weatherId = weatherId
        self.zip = zip
        self.id = id
    }
    
}
