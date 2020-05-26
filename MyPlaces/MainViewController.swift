//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 25.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
   
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //при загрузке прилодения, достаем инфу из бд
        //self - потому что нам нужена модель, а не тип Place
        places = realm.objects(Place.self)
        
        
    }
    
    // MARK: - Table view data source
   
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //если массив пустой, то выдай 0, иначе кол-во элементов
        return places.isEmpty ? 0 : places.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]

        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
       
        //скругляем фото
        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        //обрезаем края фото
        cell.imageOfPlace?.clipsToBounds = true
        
        return cell
    }
    
    //MARK: - Table view delegate
    //действие по свайпу
    //Данный метод избыточен, так как у нас только одно действие для свайпа 
    /**
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    */
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    
     // MARK: - Navigation
     //передача данных для редактирования через тапанье на ячейку
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail" else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let place = places[indexPath.row]
        let newPlaceVC = segue.destination as! NewPlaceViewController
        newPlaceVC.currentPlace = place
     }
     
    
    //метод для возвращения обратно с окна добавления
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
        
    }
    
}
