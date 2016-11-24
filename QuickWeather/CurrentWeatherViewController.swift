//
//  CurrentWeatherViewController.swift
//  QuickWeather
//
//  Created by Calvin Truong on 11/3/16.
//  Copyright © 2016 Calvin Truong. All rights reserved.
//

import UIKit
import Alamofire

class CurrentWeatherViewController: UIViewController {
    

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    var currentWeather = WeatherModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        newQuery(place: "San+Jose");
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    
    func newQuery(place: String) {
        
        //URL for Weather API
        let url = "http://api.openweathermap.org/data/2.5/weather?zip=" + place + "&units=imperial&appid=79351b4282c4cfd4998fa02965fc0326"
        
        //Request JSON
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value {
                let json = JSON(result)
                
                //get values
                let name = json["name"].stringValue
                let deg = json["main"]["temp"].intValue
                let desc = json["weather"][0]["description"].stringValue
          
                //set values
                self.currentWeather.placeName = name
                self.currentWeather.degrees = deg
                self.currentWeather.description = desc
            }
            
            //update view
            self.updateCurrentWeatherView()
        }
    }
    
    func updateCurrentWeatherView() {
        self.nameLabel.text = self.currentWeather.placeName
        self.tempLabel.text = String(self.currentWeather.degrees) + " °F"
        self.descLabel.text = self.currentWeather.description.capitalized
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

