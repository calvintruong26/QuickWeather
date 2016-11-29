//
//  CurrentWeatherViewController.swift
//  QuickWeather
//
//  Created by Calvin Truong on 11/3/16.
//  Copyright © 2016 Calvin Truong. All rights reserved.
//

import UIKit
import Alamofire
import SQLite

class CurrentWeatherViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    var currentWeather = WeatherModel()
    
    let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
    
    var db = try! Connection()
        
    let weather = Table("weather")
    let zip = Expression<String>("zip")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = try! Connection("\(path)/favoritesDB")
        
    
        try? db.run(weather.create { t in
            t.column(zip, primaryKey: true)
        })
        
        
        searchBar.delegate = self
        
        newQuery(zip: "95192");
        
        nameLabel.adjustsFontSizeToFitWidth = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WeeklyWeatherViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    
    }

    
    func newQuery(zip: String) {
        
        //URL for Weather API
        let url = "http://api.openweathermap.org/data/2.5/weather?zip=" + zip + "&units=imperial&appid=79351b4282c4cfd4998fa02965fc0326"
        
        //Request JSON
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value {
                let json = JSON(result)
                
                //check if http status is 200
                if (json["cod"].intValue == 200) {
                    
                    //get values
                    let name = json["name"].stringValue
                    let deg = json["main"]["temp"].intValue
                    let desc = json["weather"][0]["description"].stringValue
              
                    //set values
                    self.currentWeather.zip = zip
                    self.currentWeather.placeName = name
                    self.currentWeather.degrees = deg
                    self.currentWeather.description = desc
                        
                    //update view
                    self.updateCurrentWeatherView()
                }
                
                //http failed
                else {
                    self.errorAlert()
                }
            }
                
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
    
    @IBAction func saveToFavs(_ sender: UIButton) {

        
        do {
            let rowid = try db.run(weather.insert(zip <- currentWeather.zip))
            print("inserted id: \(rowid)")
        } catch {
            print("insertion failed: \(error)")
        }
        
        for instance in try! db.prepare(weather) {
            print(instance[zip])
        }
    }
    
    func errorAlert() {
        let title = "Invalid Zip Code"
        let message = "Error: You entered an invalid Zip Code. Please try again."
        let okText = "OK"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(okayButton)
        
        present(alert, animated: true, completion: nil)
    }
    

}

