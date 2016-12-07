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
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var descLabel: UILabel!
    
    var currentWeather = WeatherModel()
    
    let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
    
    var db = try! Connection()
        
    let weather = Table("weather")
    let id = Expression<Int>("id")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        db = try! Connection("\(path)/favoritesDB")
        
        //try? db.run(weather.drop(ifExists: true))
        
        try? db.run(weather.create { t in
            t.column(id, primaryKey: true)
        })
        
        
        searchBar.delegate = self
        
        newQuery(place: "95192,US");
        
        nameLabel.adjustsFontSizeToFitWidth = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WeeklyWeatherViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    
    }

    
    func newQuery(place: String) {
        
        //URL for Weather API
        let url = "http://api.openweathermap.org/data/2.5/weather?q=" + place + "&units=imperial&appid=79351b4282c4cfd4998fa02965fc0326"
        
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
                    let icon = json["weather"][0]["icon"].stringValue
                    let id = json["id"].intValue
              
                    //set values
                    //self.currentWeather.zip = zip
                    self.currentWeather.placeName = name
                    self.currentWeather.degrees = deg
                    self.currentWeather.description = desc
                    self.currentWeather.icon = icon
                    self.currentWeather.id = id
                        
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
        self.imageView.image = UIImage(named: self.currentWeather.icon)
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var text = searchBar.text!
        text = text.replacingOccurrences(of: " ", with: "+")

        let zipCode = text
        searchBar.text = ""
        newQuery(place: zipCode)
        dismissKeyboard()

    }
    
    @IBAction func saveToFavs(_ sender: UIButton) {

        
        do {
            let rowid = try db.run(weather.insert(id <- currentWeather.id))
            print("inserted id: \(rowid)")
        } catch {
            print("insertion failed: \(error)")
        }
        
        for instance in try! db.prepare(weather) {
            print(instance[id])
        }
    }
    
    func errorAlert() {
        let title = "Invalid Entry"
        let message = "Error: You entered an invalid place. Please try again."
        let okText = "OK"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(okayButton)
        
        present(alert, animated: true, completion: nil)
    }
    

}

