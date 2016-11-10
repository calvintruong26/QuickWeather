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
    

    @IBOutlet var nameLabel: UILabel!

    
    var currentWeather = CurrentWeatherModel(zip: "12345", placeName: "Imaginary Place", degrees: 75, desc: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width*0.8, height: self.view.frame.width/10)
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 40)
        nameLabel.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/6)
        nameLabel.textAlignment = .center

    }

    
    func newQuery(zipCode: String) {
        let url = "http://api.openweathermap.org/data/2.5/weather?zip=" + zipCode + "&units=imperial&appid=79351b4282c4cfd4998fa02965fc0326"
        
        
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value {
                let json = JSON(result)
                
                //get values
                let name = json["name"].stringValue
                //let deg = json["main"]["temp"].intValue
                
                //set values
                self.currentWeather.zip = zipCode
                self.currentWeather.placeName = name
                //self.currentWeather.degrees = deg
            }
        }
        
        updateCurrentWeatherView()
    }
    
    func updateCurrentWeatherView() {
        self.nameLabel.text = self.currentWeather.placeName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

//Alamofire.request(url).responseJSON { response in
//    if let result = response.result.value as? NSDictionary {
//        let name = result["name"]
//        
//        self.label.text = name as! String?
//    }
//    
//}
