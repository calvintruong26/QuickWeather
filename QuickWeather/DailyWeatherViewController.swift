//
//  SecondViewController.swift
//  QuickWeather
//
//  Created by Calvin Truong on 11/3/16.
//  Copyright © 2016 Calvin Truong. All rights reserved.
//

import UIKit
import Foundation
import Alamofire


class DailyWeatherViewController: UIViewController {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeOneLabel: UILabel!
    
    @IBOutlet weak var timeTwoLabel: UILabel!
    
    @IBOutlet weak var timeThreeLabel: UILabel!
    
    @IBOutlet weak var timeFourLabel: UILabel!
    
    @IBOutlet weak var timeFiveLabel: UILabel!
    
    @IBOutlet weak var timeSixLabel: UILabel!
    
    @IBOutlet weak var timeSevenLabel: UILabel!
    
    @IBOutlet weak var timeEightLabel: UILabel!
    
    @IBOutlet weak var tempOneLabel: UILabel!
    
    @IBOutlet weak var tempTwoLabel: UILabel!
    
    @IBOutlet weak var tempThreeLabel: UILabel!
    
    @IBOutlet weak var tempFourLabel: UILabel!
    
    @IBOutlet weak var tempFiveLabel: UILabel!
    
    @IBOutlet weak var tempSixLabel: UILabel!
    
    @IBOutlet weak var tempSevenLabel: UILabel!
    
    @IBOutlet weak var tempEightLabel: UILabel!
    
    @IBOutlet weak var imgOne: UIImageView!
    
    @IBOutlet weak var imgTwo: UIImageView!
    
    @IBOutlet weak var imgThree: UIImageView!
    
    @IBOutlet weak var imgFour: UIImageView!
    
    @IBOutlet weak var imgFive: UIImageView!
    
    @IBOutlet weak var imgSix: UIImageView!
    
    @IBOutlet weak var imgSeven: UIImageView!
    
    @IBOutlet weak var imgEight: UIImageView!
    
    var firstHour = WeatherModel()
    var secondHour = WeatherModel()
    var thirdHour = WeatherModel()
    var fourthHour = WeatherModel()
    var fifthHour = WeatherModel()
    var sixthHour = WeatherModel()
    var seventhHour = WeatherModel()
    var eighthHour = WeatherModel()
    
    var weatherList : [WeatherModel] = [WeatherModel(), WeatherModel(), WeatherModel(), WeatherModel(), WeatherModel(), WeatherModel(), WeatherModel(), WeatherModel()]
    
    var imgs : [UIImageView] = [UIImageView(), UIImageView(), UIImageView(), UIImageView(), UIImageView(), UIImageView(), UIImageView(), UIImageView()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        weatherList[0] = firstHour
        weatherList[1] = secondHour
        weatherList[2] = thirdHour
        weatherList[3] = fourthHour
        weatherList[4] = fifthHour
        weatherList[5] = sixthHour
        weatherList[6] = seventhHour
        weatherList[7] = eighthHour
        
        imgs[0] = imgOne
        imgs[1] = imgTwo
        imgs[2] = imgThree
        imgs[3] = imgFour
        imgs[4] = imgFive
        imgs[5] = imgSix
        imgs[6] = imgSeven
        imgs[7] = imgEight

        newQuery(place: "New+York+City")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func newQuery(place: String) {
        
        //URL for WeatherAPI
        let url = "http://api.openweathermap.org/data/2.5/forecast?q=" + place + "&cnt=8&units=imperial&mode=json&appid=79351b4282c4cfd4998fa02965fc0326"
        
        //Request JSON
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value {
                let json = JSON(result)
                
                //get values
                let name = json["city"]["name"].stringValue
                let long = json["city"]["coord"]["lon"].intValue
                let lat = json["city"]["coord"]["lat"].intValue
                var offset : Double = 0
                
                //Google Maps Time Zone API
                let timezoneReqUrl = "https://maps.googleapis.com/maps/api/timezone/json?location=" + String(lat) + "," + String(long) + "&timestamp=1458000000&key=AIzaSyBeeH88SEWNZLe0CB4wlkCa0np8vkLlxuo"
                
                //Request JSON
                Alamofire.request(timezoneReqUrl).responseJSON { TZresponse in
                    if let TZresult = TZresponse.result.value {
                        let TZjson = JSON(TZresult)
                        
                        //get TimeZone difference
                        offset = TZjson["rawOffset"].doubleValue
                        
                    }
                    
                    //format date
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "hh:mma"
                    dayTimePeriodFormatter.timeZone = TimeZone(abbreviation: "GMT")
                    
                    //get every weather model
                    for i in 0...7 {
                        let deg = json["list"][i]["main"]["temp"].intValue
                        let timestamp = json["list"][i]["dt"].doubleValue + offset
                        let timestampString = dayTimePeriodFormatter.string(from: Date(timeIntervalSince1970: timestamp))
                        let icon = json["list"][i]["weather"][0]["icon"].stringValue
                        
                        self.weatherList[i].degrees = deg
                        self.weatherList[i].placeName = name
                        self.weatherList[i].timestamp = timestampString
                        self.weatherList[i].icon = icon
                    }
                    
                    //update view
                    self.updateDailyWeatherView()
                }
            }
        }
    }

    func updateDailyWeatherView() {
        self.nameLabel.text = self.weatherList[0].placeName
        self.tempOneLabel.text = String(self.weatherList[0].degrees) + " °F"
        self.tempTwoLabel.text = String(self.weatherList[1].degrees) + " °F"
        self.tempThreeLabel.text = String(self.weatherList[2].degrees) + " °F"
        self.tempFourLabel.text = String(self.weatherList[3].degrees) + " °F"
        self.tempFiveLabel.text = String(self.weatherList[4].degrees) + " °F"
        self.tempSixLabel.text = String(self.weatherList[5].degrees) + " °F"
        self.tempSevenLabel.text = String(self.weatherList[6].degrees) + " °F"
        self.tempEightLabel.text = String(self.weatherList[7].degrees) + " °F"
        self.timeOneLabel.text = self.weatherList[0].timestamp
        self.timeTwoLabel.text = self.weatherList[1].timestamp
        self.timeThreeLabel.text = self.weatherList[2].timestamp
        self.timeFourLabel.text = self.weatherList[3].timestamp
        self.timeFiveLabel.text = self.weatherList[4].timestamp
        self.timeSixLabel.text = self.weatherList[5].timestamp
        self.timeSevenLabel.text = self.weatherList[6].timestamp
        self.timeEightLabel.text = self.weatherList[7].timestamp

        for i in 0...7 {
            if let url = NSURL(string: "http://openweathermap.org/img/w/" + self.weatherList[i].icon + ".png") {
                if let data = NSData(contentsOf: url as URL) {
                    imgs[i].image = UIImage(data: data as Data)
                }
            }
        }
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    


}

