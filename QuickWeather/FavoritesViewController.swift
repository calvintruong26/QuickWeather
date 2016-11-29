//
//  FavoritesViewController.swift
//  QuickWeather
//
//  Created by Calvin Truong on 11/28/16.
//  Copyright © 2016 Calvin Truong. All rights reserved.
//

import UIKit
import SQLite
import Alamofire

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
        ).first!
    
    var db = try! Connection()
    
    let weather = Table("weather")
    let zip = Expression<String>("zip")
    
    
    // Data model: These strings will be the data for the table view cells
    
    var list = [WeatherModel]()
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = try! Connection("\(path)/favoritesDB")
        
        
        try? db.run(weather.create { t in
            t.column(zip, primaryKey: true)
        })
        
        // Register the table view cell class and its reuse id
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        //updateList()
    }
    
    func updateList() {
        list = [WeatherModel]()
        for instance in try! db.prepare(weather) {
            var weatherInstance = WeatherModel()
            weatherInstance.zip = instance[zip]
            
            
            //URL for Weather API
            let url = "http://api.openweathermap.org/data/2.5/weather?zip=" + weatherInstance.zip + "&units=imperial&appid=79351b4282c4cfd4998fa02965fc0326"
            
            //Request JSON
            Alamofire.request(url).responseJSON { response in
                if let result = response.result.value {
                    let json = JSON(result)
                    
                    //check if http status is 200
                    if (json["cod"].intValue == 200) {
                        
                        //get values
                        let name = json["name"].stringValue
                        let deg = json["main"]["temp"].intValue
                        
                        //set values
                        weatherInstance.placeName = name
                        weatherInstance.degrees = deg
                        
                        //update view
                        //self.updateCurrentWeatherView()
                    }
                        
                        //http failed
                    else {
                        self.errorAlert()
                    }
                }
                
                self.list.append(weatherInstance)
                self.tableView.reloadData()
            }
            
            
        }
    }
    
    func errorAlert() {
        let title = "Something went wrong"
        let message = "Error: We had trouble loading one or more of your favorites. Please try again later."
        let okText = "OK"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(okayButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateList()
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    
    // create a cell for each table view row
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? FavoritesTableViewCell ?? FavoritesTableViewCell()
        
        let object = list[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = object.placeName
        cell.tempLabel.text = String(object.degrees) + " °F"
        cell.zip = object.zip
        
        return cell
    }
    

    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            let currentCell = tableView.cellForRow(at: indexPath) as! FavoritesTableViewCell
            let rm = weather.filter(zip == currentCell.zip)
            try? db.run(rm.delete())
            self.list.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
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
