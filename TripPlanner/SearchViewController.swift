//
//  SearchViewController.swift
//  TripPlanner
//
//  Created by Ronnie Wang on 3/1/18.
//  Copyright © 2018 DeAnza. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

class SearchViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet var weatherTable: UITableView!
    var forecastData = [Weather]()
    let category = ["bar", "cafe", "casino", "library", "museum", "park", "restaurant", "zoo"]
    var type = "Bar"
    var latitude : CLLocationDegrees = -33.86
    var longitude : CLLocationDegrees = 151.20
    var begin = "Today"
    var days = 3

    @IBAction func RadiusSlider(_ sender: UISlider) {
        radiusLabel.text = String(Int(sender.value) * 500)
    }
    
    @IBAction func SearchButton(_ sender: Any) {
        let link = "https://maps.googleapis.com/maps/api/place/search/json?location=\(latitude),\(longitude)&radius=" + radiusLabel.text! + "&type=\(type)&key=AIzaSyBndTX7QCf6aFhY6DJMsqX9MHxp-6JssvA"
        guard let url = URL(string: link)
            else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            /*
            if let response = response {
                print(response)
            }
            */
            
            guard let data = data else {return}
            
                do {
                    
                    let json = JSON(data)
                    
                    //Search results given radius and category
                    //Write to data collection
                    for k in 0..<json["results"].count
                    {
                        //name: property's name; lat, lng: latitude, longitude
                        //rating: users' rating, vicinity, open: whether the property is open now(true or false)
                        //if some value is missing (e.g. no rating value), returns default value or empty (Won't crash the app)
                        let nameSearch : String = json["results"][k]["name"].stringValue
                        let latSearch : Double = json["results"][k]["geometry"]["location"]["lat"].doubleValue
                        let lngSearch : Double = json["results"][k]["geometry"]["location"]["lng"].doubleValue
                        let ratingSearch : Double = json["results"][k]["rating"].doubleValue
                        let vicinitySearch : String = json["results"][k]["vicinity"].stringValue
                        let openSearch : Bool = json["results"][k]["opening_hours"]["open_now"].boolValue
                        print(nameSearch)
                        print(vicinitySearch)
                        print(ratingSearch)
                        print(latSearch,lngSearch)
                        print(openSearch)
                    }
                    
                } catch {
                    print(error)
                }
            
            }.resume()
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = category[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Search View"
        var coordinates: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/search/json?location=" + String(latitude) + "," + String(longitude) + "&radius=10000&keyword=things%20to%20do&rankby=prominence&key=AIzaSyBndTX7QCf6aFhY6DJMsqX9MHxp-6JssvA"
            ) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
         /*
             if let response = response {
                print(response)
            }
         */
            if let data = data {
                
                do {
                    let json = JSON(data)
                    
                    //After user click "Start Planning", this view loads the search results of TTD(Things To Do) for given address within 10km radius
                    //Write to data collection
                    for i in 0..<json["results"].count
                    {
                        //name: property's name; lat, lng: latitude, longitude
                        //rating: users' rating, vicinity, open: whether the property is open now(true or false)
                        //if some value is missing (e.g. no rating value), returns default value or empty (Won't crash the app)
                        let nameTTD : String = json["results"][i]["name"].stringValue
                        let latTTD : Double = json["results"][i]["geometry"]["location"]["lat"].doubleValue
                        let lngTTD : Double = json["results"][i]["geometry"]["location"]["lng"].doubleValue
                        let ratingTTD : Double = json["results"][i]["rating"].doubleValue
                        let vicinityTTD : String = json["results"][i]["vicinity"].stringValue
                        let openTTD : Bool = json["results"][i]["opening_hours"]["open_now"].boolValue
                        print(nameTTD)
                        print(vicinityTTD)
                        print(ratingTTD)
                        print(latTTD,lngTTD)
                        print(openTTD)
                    }
                    
                } catch {
                    print(error)
                }
                
            }
            }.resume()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        
        getWeatherForLocation(location: String(latitude) + "," + String(longitude))
        
        weatherTable.delegate = self
        weatherTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func getWeatherForLocation (location:String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                        
                        if let weatherData = results {
                            self.forecastData = weatherData
                            
                            DispatchQueue.main.async {
                                self.weatherTable.reloadData()
                            }
                        }
                        
                    })
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return forecastData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnStr = ""
        let date = Calendar.current.date(byAdding: .day, value: section, to: Date())
        let dateFormatter = DateFormatter()
        let weatherObject = forecastData[section]
        
        dateFormatter.dateFormat = "MM/dd"
        
        returnStr = dateFormatter.string(from: date!) + " (" + "\(Int(weatherObject.temperature))°F" + ")"
        
        return returnStr
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        
        let weatherObject = forecastData[indexPath.section]
        
        cell.imageView?.sizeToFit()
        cell.imageView?.image = UIImage(named: weatherObject.icon)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        
        if let textlabel = header.textLabel {
            textlabel.font = textlabel.font.withSize(10)
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
