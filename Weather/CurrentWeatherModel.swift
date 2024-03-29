//
//  CurrentWeatherModel.swift
//  Weather
//
//  Created by Idris on 02/11/19.
//  Copyright © 2019 Idris-labs. All rights reserved.
//

import Foundation
struct CurrentWeatherModel: Decodable {
  let data: [CurrentWeather]
}

struct CurrentWeather: Decodable {
  let city_name: String
  let weather: CurrentWeatherDescription
  let temp: Double
}

struct CurrentWeatherDescription: Decodable {
  let description: String
  let code: String
}

