//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 26.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
