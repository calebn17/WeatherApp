//
//  WeatherTableViewController.swift
//  WeatherApp
//
//  Created by Caleb Ngai on 3/6/22.
//

import UIKit
import RealmSwift
import CoreLocation

class WeatherTableViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    
    let realm = try! Realm()
    //used to store all the Data in Realm DB
    var weatherRealmData: Results<WeatherRealmData>?
    //store the initial city name entered by the user
    var cityName = ""
    //this object is used mainly to store the parsed json data and send it to this VC
    var weatherModelArray: [WeatherModel] = []
    //creates an instance of the WeatherManager object to call some of its methods
    var weatherManager = WeatherManager()
    //creates an instance of the CLLocationManager in order to use CLLocation methods
    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        tableView.backgroundView?.contentMode = UIView.ContentMode.scaleAspectFill
        
        let image = UIImage()
        searchBar.backgroundImage = image
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        //sets this VC as a delegate for the WeatherManager
        weatherManager.delegate = self
        searchBar.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestLocation()
        
        //fetches data from Realm upon loading to see if there are any data that was stored
        loadWeatherRealmData()
       
    }
    

//MARK: - TableView methods
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherRealmData?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if weatherRealmData?[indexPath.row].name == nil {
            cell.textLabel?.text = "No Cities Added Yet"
            
        } else {
            var temp : String = ""
            var city: String = ""
            
            //composes the cell label from weatherRealmData
            if let weather = weatherRealmData?[indexPath.row] {
                temp = String(format: "%.2f", weather.temp)
                city = weather.name
                cell.textLabel!.text = city + "    " + temp + " F"
                print("Everything is done")
            }
            
            return cell
        }
        
        
        return cell
    }
    
//MARK: - Deleting data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.weatherRealmData?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
//MARK: - Tableview Segue/Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Sets up the segue from the Table VC to the Detail VC
        performSegue(withIdentifier: "weatherToDetails", sender: self)
    }
    
    //passes over all the relevant data to the Detail VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! WeatherDetailsViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            let weatherData = weatherRealmData?[indexPath.row]
            destinationVC.cityName = (weatherData?.name)!
            destinationVC.temp = (weatherData?.temp)!
            destinationVC.condition = (weatherData?.condition)!
            destinationVC.feelsLike = (weatherData?.feelsLike)!
            
            
            
        }
    }
    
    
}

//MARK: - WeatherMangerDelegate

extension WeatherTableViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        //grabs the parsed data from the Json/API and adds it into a WeatherRealmData object
        DispatchQueue.main.async {
            self.weatherModelArray.append(weather)
            print("didUpdateWeather")
            
            let newWeatherRealmData = WeatherRealmData()
            newWeatherRealmData.name = weather.cityName
            newWeatherRealmData.temp = weather.temperature
            newWeatherRealmData.condition = weather.conditionName
            newWeatherRealmData.feelsLike = weather.feelsLike
            self.save(data: newWeatherRealmData)
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - SearchBar Delegate

extension WeatherTableViewController: UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //whenever a city is entered in the search bar and the search button is pressed, the fetchWeather method is called to grab the data associated to that city
        cityName = searchBar.text!
        weatherManager.fetchWeather(cityName: cityName)
    }
    
    //This dismisses the keyboard when the user taps elsewhere
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }



}

//MARK: - Realm Datasource Methods

extension WeatherTableViewController {
    func save(data: WeatherRealmData) {
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
                print("Error saving category \(error)")
            }
        tableView.reloadData()
    }

    func loadWeatherRealmData() {
        weatherRealmData = realm.objects(WeatherRealmData.self)
        tableView.reloadData()
    }
    
   
}


//MARK: - CLLocationManagerDelegate


extension WeatherTableViewController: CLLocationManagerDelegate {
    //When the locationButton is pressed, this block will kick off
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //grabs the last location found by the device
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            //passes the latitude and longitude to the WeatherManager
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

