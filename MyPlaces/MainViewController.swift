//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 25.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //сортировка по возрастанию
    private var ascendingSorting = true
    private var places: Results<Place>!
    //массив с отфильтрованными результатами
    private var filtredPlaces: Results<Place>!
    //свойство, проверяющее пустая ли строка ввода
    private var searchBarIsEnpty: Bool {
        guard let text = seachController.searchBar.text else { return false }
        return text.isEmpty
    }
    //вызываем серч контроллер (из кода, без стори боард)
    //передавая nil сообщаем контроллеру, что ходим использовать тот же вью (не создавать новый)
    private let seachController = UISearchController(searchResultsController: nil)
    //возвращает true когда поисковый запрос активирован
    private var isFilteing: Bool {
        return seachController.isActive && !searchBarIsEnpty
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //при загрузке прилодения, достаем инфу из бд
        //self - потому что нам нужена модель, а не тип Place
        places = realm.objects(Place.self)
        
        
        //настроиваем серач контроллера
        //получаетелем инфы об изменении текста в строке должен быть наш класс
        seachController.searchResultsUpdater = self
        //позволит взаимодействовать с контроллером как с основным (он по началу отключен, так мы его вкл)
        seachController.obscuresBackgroundDuringPresentation = false
        //даем название для поля ввода (начальное сообщение)
        seachController.searchBar.placeholder = "Search"
        //интегрируем строку в navigation bar
        navigationItem.searchController = seachController
        //позволяет опускать строку при переходе на другой экран
        definesPresentationContext = true
    }
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //занимается фильтровкой
        if isFilteing {
            return filtredPlaces.count
        }
        
        //если массив пустой, то выдай 0, иначе кол-во элементов
        return places.isEmpty ? 0 : places.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        //выбираем что отображать (фильтрованную инфу или нет)
        var place = Place()
        
        if isFilteing {
            place = filtredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
     
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
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
        //проверяем активна ли строка поиска (при наборе ее создается новый контроллер
        //чтоб при редактированнии отфильтрованной ячейки не фильтровалась та, что находится на ее месте в родительском контроллере)
        let place: Place
        if isFilteing {
            place = filtredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        
        let newPlaceVC = segue.destination as! NewPlaceViewController
        newPlaceVC.currentPlace = place
    }
    
    
    //метод для возвращения обратно с окна добавления
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
        
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        //выбираем сегментыд контрол и какой вид сортировки
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        //метод меняет значение на противоположное (для булевых)
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = UIImage(systemName: "arrow.down")
        } else {
            reversedSortingButton.image = UIImage(systemName: "arrow.up")
        }
        sorting()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            //добавляем еще 1 элемент (выбор сортировки - убывание/возрастание)
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
    
    
    
    
}


//MARK: - создаем расширения для работы с UISearchController

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        //можем извлечь опционал, так как сам метод вызввается только в том случае, если текст есть
        filerContentForSearchText(seachController.searchBar.text!)
    }
    
    private func filerContentForSearchText(_ searchText: String) {
        
        //[c] - обозначает независимость от регистра (не важно большая или маленькая буква)
        //%@ - конкретная переменная, которую мы напишем
        //для каждого такого символа надо после происать откуда будкем брать инфу (в нашем случае - searchText)
        filtredPlaces =
            places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText,
                          searchText)
        tableView.reloadData()
    }
    
}
