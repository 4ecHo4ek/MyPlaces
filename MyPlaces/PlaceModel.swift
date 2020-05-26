//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 25.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var image:  UIImage?
    var restaurantImage: String?
    
    static let restaurantNames = [
        "Papa Jons",
        "Tanuki",
        "Do-do"
    ]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        for place in restaurantNames {
            places.append(Place(name: place, location: "Moscow", type: "Cafe", image: nil, restaurantImage: place))
        }
        return places
    }
}
