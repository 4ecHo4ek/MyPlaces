//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 25.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
   
    let places = [
        Place(name: "Papa Jons", location: "Moscow", type: "Pizza", image: "Papa Jons"),
        Place(name: "Tanuki", location: "Moscow", type: "Susi", image: "Tanuki"),
        Place(name: "Do-do", location: "Moscow", type: "Pizza", image: "Do-do")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Table view data source
   
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        cell.nameLabel?.text = places[indexPath.row].name
        cell.locationLabel.text = places[indexPath.row].location
        cell.typeLabel.text = places[indexPath.row].type
        cell.imageOfPlace?.image = UIImage(named: places[indexPath.row].image)
        //скругляем фото
        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        //обрезаем края фото
        cell.imageOfPlace?.clipsToBounds = true
        
        return cell
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //метод для возвращения обратно с окна добавления
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {
        
    }
    
}
