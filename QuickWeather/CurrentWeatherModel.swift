//
//  CurrentWeatherModel.swift
//  QuickWeather
//
//  Created by Calvin Truong on 11/8/16.
//  Copyright © 2016 Calvin Truong. All rights reserved.
//

import Foundation

class CurrentWeatherModel {
    var zip : String?
    var placeName : String?
    var degrees : Int?
    var description : String?
    
    init(zip: String, placeName: String, degrees: Int, desc: String) {
        self.zip = zip
        self.placeName = placeName
        self.degrees = degrees
        self.description = desc
    }
    
}
