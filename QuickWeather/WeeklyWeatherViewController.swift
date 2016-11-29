//
//  WeeklyWeatherViewController.swift
//  QuickWeather
//
//  Created by Calvin Truong on 11/24/16.
//  Copyright © 2016 Calvin Truong. All rights reserved.
//

import UIKit
import Alamofire

class WeeklyWeatherViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dayOneLabel: UILabel!
    
    @IBOutlet weak var dayTwoLabel: UILabel!
    
    @IBOutlet weak var dayThreeLabel: UILabel!
    
    @IBOutlet weak var dayFourLabel: UILabel!
    
    @IBOutlet weak var dayFiveLabel: UILabel!
    
    @IBOutlet weak var daySixLabel: UILabel!
    
    @IBOutlet weak var daySevenLabel: UILabel!
    
    @IBOutlet weak var tempOneLabel: UILabel!
    
    @IBOutlet weak var tempTwoLabel: UILabel!
    
    @IBOutlet weak var tempThreeLabel: UILabel!
    
    @IBOutlet weak var tempFourLabel: UILabel!
    
    @IBOutlet weak var tempFiveLabel: UILabel!
    
    @IBOutlet weak var tempSixLabel: UILabel!
    
    @IBOutlet weak var tempSevenLabel: UILabel!
    
    @IBOutlet weak var imgOne: UIImageView!
    
    @IBOutlet weak var imgTwo: UIImageView!
    
    @IBOutlet weak var imgThree: UIImageView!
    
    @IBOutlet weak var imgFour: UIImageView!
    
    @IBOutlet weak var imgFive: UIImageView!
    
    @IBOutlet weak var imgSix: UIImageView!
    
    @IBOutlet weak var imgSeven: UIImageView!
    
    var dayOne = WeatherModel()
    var dayTwo = WeatherModel()
    var dayThree = WeatherModel()
    var dayFour = WeatherModel()
    var dayFive = WeatherModel()
    var daySix = WeatherModel()
    var daySeven = WeatherModel()
    
    var weatherList : [WeatherModel] = [WeatherModel(), WeatherModel(), WeatherModel(), WeatherModel(), WeatherModel(), WeatherModel(), WeatherModel()]
    
    var imgs : [UIImageView] = [UIImageView(), UIImageView(), UIImageView(), UIImageView(), UIImageView(), UIImageView(), UIImageView()]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.adjustsFontSizeToFitWidth = true
        
        searchBar.delegate = self
        
        weatherList[0] = dayOne
        weatherList[1] = dayTwo
        weatherList[2] = dayThree
        weatherList[3] = dayFour
        weatherList[4] = dayFive
        weatherList[5] = daySix
        weatherList[6] = daySeven
        
        imgs[0] = imgOne
        imgs[1] = imgTwo
        imgs[2] = imgThree
        imgs[3] = imgFour
        imgs[4] = imgFive
        imgs[5] = imgSix
        imgs[6] = imgSeven

        newQuery(zip: "95192")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WeeklyWeatherViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newQuery(zip: String) {
        
        let url = "http://api.openweathermap.org/data/2.5/forecast/daily?zip=" + zip + "&mode=json&units=imperial&cnt=8&appid=79351b4282c4cfd4998fa02965fc0326"
        
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value {
                let json = JSON(result)
                
                //check to see if http status is 200
                if (json["cod"].intValue == 200) {
                    
                    //format date
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "EEEEEE MMM dd"
                    
                    //get name of place
                    let name = json["city"]["name"].stringValue
                    
                    //get weather for next 7 days
                    for i in 0...6 {
                        let dt = json["list"][i+1]["dt"].doubleValue
                        let timestampString = dayTimePeriodFormatter.string(from: Date(timeIntervalSince1970: dt))
                        let icon = json["list"][i+1]["weather"][0]["icon"].stringValue
                        let deg = json["list"][i+1]["temp"]["day"].intValue
                        
                        self.weatherList[i].degrees = deg
                        self.weatherList[i].timestamp = timestampString
                        self.weatherList[i].icon = icon
                        self.weatherList[i].placeName = name
                    }
                    
                    //update view
                    self.updateWeeklyWeatherView()
                }
                 
                //http failed
                else {
                    self.errorAlert()
                }
            }
        }
    
    }
    
    func updateWeeklyWeatherView() {
        self.nameLabel.text = self.weatherList[0].placeName
        self.tempOneLabel.text = String(self.weatherList[0].degrees) + " °F"
        self.tempTwoLabel.text = String(self.weatherList[1].degrees) + " °F"
        self.tempThreeLabel.text = String(self.weatherList[2].degrees) + " °F"
        self.tempFourLabel.text = String(self.weatherList[3].degrees) + " °F"
        self.tempFiveLabel.text = String(self.weatherList[4].degrees) + " °F"
        self.tempSixLabel.text = String(self.weatherList[5].degrees) + " °F"
        self.tempSevenLabel.text = String(self.weatherList[6].degrees) + " °F"
        
        self.dayOneLabel.text = self.weatherList[0].timestamp
        self.dayTwoLabel.text = self.weatherList[1].timestamp
        self.dayThreeLabel.text = self.weatherList[2].timestamp
        self.dayFourLabel.text = self.weatherList[3].timestamp
        self.dayFiveLabel.text = self.weatherList[4].timestamp
        self.daySixLabel.text = self.weatherList[5].timestamp
        self.daySevenLabel.text = self.weatherList[6].timestamp
        
        
        for i in 0...6 {
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text!
        let numReference = "0123456789"
        var allNumbers = true
        
        //check if text is non-empty and zip code length
        if (text != "" && text.characters.count == 5) {
            
            //check to see if all characters are numbers
            for i in 0...4 {
                let index = text.index((text.startIndex), offsetBy: i)
                let char = text[index]
                let str = String(describing: char)
                if (!numReference.contains(str)) {
                    allNumbers = false
                }
            }
            
            //if format correct, make new query
            if (allNumbers) {
                let zipCode = searchBar.text
                searchBar.text = ""
                newQuery(zip: zipCode!)
                dismissKeyboard()
            }
                
                //else create error message
            else {
                self.errorAlert()
            }
            
        }
            
            //else create error message
        else {
            self.errorAlert()
        }
    }
    
    func errorAlert() {
        let title = "Error"
        let message = "You entered an invalid Zip Code. Please try again."
        let okText = "OK"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(okayButton)
        
        present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
