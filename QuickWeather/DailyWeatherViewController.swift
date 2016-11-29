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


class DailyWeatherViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var list = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
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
    
    let cellReuseIdentifier = "cell"
    
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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        nameLabel.adjustsFontSizeToFitWidth = true
        
        searchBar.delegate = self
        
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

        newQuery(zip: "94122")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WeeklyWeatherViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func newQuery(zip: String) {
        
        //URL for WeatherAPI
        let url = "http://api.openweathermap.org/data/2.5/forecast?zip=" + zip + "&cnt=8&units=imperial&mode=json&appid=79351b4282c4cfd4998fa02965fc0326"
        
        //Request JSON
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value {
                let json = JSON(result)
                
                //check to see if http status is 200
                if (json["cod"].intValue == 200) {
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
                            let weatherId = json["list"][i]["weather"][0]["id"].intValue
                            
                            self.weatherList[i].degrees = deg
                            self.weatherList[i].placeName = name
                            self.weatherList[i].timestamp = timestampString
                            self.weatherList[i].icon = icon
                            self.weatherList[i].weatherId = weatherId
                        }
                        //get recommended items
                        self.getItemRecommendations()
                        
                        //update view
                        self.updateDailyWeatherView()
                    }
                }
                    
                //http failed
                else {
                    self.errorAlert()
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
        
        self.tableView.reloadData()
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
    
    func getItemRecommendations() {
        var itemList = [String]()
        for weather in weatherList {
            if (weather.weatherId >= 200 && weather.weatherId < 300) {
                itemList.append("Heavy Rain Jacket")
                itemList.append("Rainboots")
                itemList.append("Waterproof Pants")
            }
            else if (weather.weatherId >= 300 && weather.weatherId < 400) {
                itemList.append("Rain Jacket")
                itemList.append("Umbrella")
            }
            else if (weather.weatherId >= 500 && weather.weatherId < 600) {
                itemList.append("Rain Jacket")
                itemList.append("Umbrella")
                itemList.append("Rainboots")
            }
            else if (weather.weatherId >= 600 && weather.weatherId < 700) {
                itemList.append("Snow Shoes")
                itemList.append("Snow Jacket")
                itemList.append("Hand Warmers")
                itemList.append("Gloves or Mittens")
                itemList.append("Snow Pants")
            }
            else if (weather.weatherId >= 700 && weather.weatherId < 800) {
                itemList.append("Windbreaker Jacket")
                if (weather.weatherId != 701 && weather.weatherId != 741) {
                    itemList.append("Face Mask")
                    itemList.append("Scarf")
                }
            }
            else if (weather.weatherId == 800 || weather.weatherId == 951) {
                if (weather.weatherId != 951 && weather.icon.contains("d")) {
                    itemList.append("Sunglasses")
                }
                if (weather.degrees > 65) {
                    itemList.append("Light Layers")
                }
                else {
                    itemList.append("Warm Layers")
                }
            }
            else if (weather.weatherId >= 801 && weather.weatherId < 805) {
                if (weather.degrees > 65) {
                    itemList.append("Light Layers")
                }
                else {
                    itemList.append("Warm Layers")
                }
            }
            else if (weather.weatherId >= 952 && weather.weatherId <= 959) {
                itemList.append("Windbreaker")
            }
            else if (weather.weatherId >= 960) {
                itemList.append("WARNING: Dangerous Conditions!")
            }
            else if (weather.weatherId >= 900 && weather.weatherId <= 910) {
                itemList.append("WARNING: Dangerous Conditions!")
            }
        }
        let uniqueItemList = Array(Set(itemList))
        self.list = uniqueItemList
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.list[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }

}

