//
//  WeatherViewController.swift
//  Weather
//
//  Created by Idris on 02/11/19.
//  Copyright © 2019 Idris-labs. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SVProgressHUD

class WeatherViewController: UIViewController {
  var dailyWeatherList: DailyWeatherViewModel!
  var currentWeather: CurrentWeatherViewModel?
  var hourlyWeatherList: HourlyWeatherViewModel!
  let locationManager = CLLocationManager()
  var location:CLLocationManager!
  var keywords: String?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var locationSearchBar: UISearchBar!
  @IBOutlet weak var tempratureLabel: UILabel!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var currentWeatherImage: UIImageView!
  @IBOutlet weak var hourlyWeatherCollectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    self.locationSearchBar.delegate = self
  }
  
  private func setupWeather(keyword: String) {
    SVProgressHUD.show()
    self.getCurrentWeather(keyword)
    self.setupTableView(keyword)
    self.getHourlyWeather(keyword)
    
  }
  
  @IBAction func currentLocationTapped(_ sender: UIBarButtonItem) {
    self.location.startUpdatingLocation()
  }
  @IBAction func refreshLocation(_ sender: UIBarButtonItem) {
    if let keyword = self.keywords {
      self.setupWeather(keyword: keyword)
    }
  }
  private func getCurrentWeather(_ place: String) {
    Webservice().getCurrentWeather(place) { (result) in
      if let result = result {
        self.currentWeather = CurrentWeatherViewModel(result)
        self.setupView()
      }
    }
  }
  
  private func setupView() {
    if let weather = self.currentWeather {
      self.cityLabel.text = weather.cityNameWeather
      self.tempratureLabel.text = weather.tempratureWeather
      self.descriptionLabel.text = weather.descriptionWeather
      self.currentWeatherImage.image = UIImage(named: weather.imageWeather)
    }
  }
  
  
  private func setupTableView(_ city: String){
    Webservice().getDailyWeather(city) { (response) in
      if let response = response {
        self.dailyWeatherList = DailyWeatherViewModel(response)
        DispatchQueue.main.async {
          self.tableView.reloadData()
          self.tableView.dataSource = self
          self.tableView.delegate = self
        }
      }
    }
  }
  
  private func getHourlyWeather(_ city: String) {
    Webservice().getHourlyWeather(city) { (response) in
      if let response = response {
        self.hourlyWeatherList = HourlyWeatherViewModel(hourlyListWeather: response)
        DispatchQueue.main.async {
          self.hourlyWeatherCollectionView.reloadData()
          self.hourlyWeatherCollectionView.delegate = self
          self.hourlyWeatherCollectionView.dataSource = self
          SVProgressHUD.dismiss()
        }
      }
    }
  }
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dailyWeatherList.numberOfRowsInSection(section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "DailyWeatherCell", for: indexPath) as! DailyWeatherTableViewCell
    let dailyWeatherVM = self.dailyWeatherList.dailyWeatherAtIndex(indexPath.row)
    cell.dayLabel.text = Helper().dateConverter(dailyWeatherVM.datetime)
    cell.tempratureLabel.text = "\(Int(dailyWeatherVM.temp))°"
    cell.dailyWeatherImage.image = UIImage(named: Helper().checkImageByCode(dailyWeatherVM.weather.code))
    return cell
  }
}


extension WeatherViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let keyword = searchBar.text {
      self.keywords = keyword
      self.setupWeather(keyword: keyword)
    }
    self.locationSearchBar.resignFirstResponder()
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.locationSearchBar.resignFirstResponder()
  }
}

extension WeatherViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.location = manager
    self.location.stopUpdatingLocation()
    if let node = self.location.location {
      let location = CLLocation(latitude: node.coordinate.latitude, longitude: node.coordinate.longitude)
      let geocoder = CLGeocoder()
      geocoder.reverseGeocodeLocation(location) { (response, error) in
        if let error = error {
          fatalError()
        }
        else {
          if let geocodeLocation = response {
            guard let placemark = geocodeLocation.first else {return}
            if let place = placemark.subLocality {
              self.setupWeather(keyword: place)
            }
          }
        }
      }
    }
  }
}


extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.hourlyWeatherList.numberOfRowsInSection(section)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.hourlyWeatherCollectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCollectionCell", for: indexPath) as! HourlyWeatherCollectionViewCell
    
    let hourlyWeatherVM = self.hourlyWeatherList.hourlyWeatherAtIndex(indexPath.row)
    
    cell.timeLable.text = Helper().convertDateTime( hourlyWeatherVM.timestamp_local)
    cell.tempratureLabel.text = "\(Int(hourlyWeatherVM.temp))°"
    cell.hourlyImage.image = UIImage(named: Helper().checkImageByCode(hourlyWeatherVM.weather.code)) 
    return cell
  }
  
  
}
