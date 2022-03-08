//
//  ViewController.swift
//  WeatherApp
//
//  Created by Caleb Ngai on 3/6/22.
//

import UIKit
import RealmSwift

class WeatherDetailsViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    
    @IBOutlet weak var feelsLikeLabel: UILabel!
    var weatherDetailsData: Results<WeatherDetailsData>?
    let realm = try! Realm()
    
    
    var cityName:String = "No city Name"
    var temp: Double = 0.00
    var condition: String = ""
    var feelsLike: Double = 0.00

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityLabel.text = cityName
        tempLabel.text = String(temp)
        conditionImage.image = UIImage(systemName: condition)
        feelsLikeLabel.text = String(feelsLike)
        
        
        
    }
    
}




