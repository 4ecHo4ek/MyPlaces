//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 25.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData:  Data?
    @objc dynamic var date = Date()
    
//назначенный инициализатор
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        //пустой инит нужен для дальнейшего редактирования имеющейся ячейки
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }
   
}
