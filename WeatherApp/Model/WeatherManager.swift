//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Caleb Ngai on 3/6/22.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    //this allows the WeatherManager to pass over the decoded Json in a WeatherModel object to the Table VC
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let apiKey = "3316299453be59460e1dd4edd00c4851"
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=3316299453be59460e1dd4edd00c4851&units=imperial"
    
    var delegate: WeatherManagerDelegate?
    
    //function called by the Table VC that passes a city name to the WeatherManager to grab the weather data
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        print(urlString)
        //makes the API call and returns a WeatherModel object to the Table VC
        performRequest(with: urlString)
    }
    
    //function called by the Table VC that passes latitude and longitude to the WeatherManager to grab the weather data
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        //makes the API call and returns a WeatherModel object to the Table VC
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        print("Parsed data")
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let feelsLike = decodedData.main.feels_like
            print("Parsing data")
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, feelsLike: feelsLike)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
}


