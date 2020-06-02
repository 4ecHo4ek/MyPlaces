//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 25.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            //скругляем фото
              imageOfPlace?.layer.cornerRadius = imageOfPlace.frame.size.height / 2
              //обрезаем края фото
              imageOfPlace?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            //запрещаем редактирование звезды при нажатии (на главном экране)
            cosmosView.settings.updateOnTouch = false
        }
    }
    
    

}
