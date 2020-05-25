//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 25.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //меняем разлиновку после наших строк ввода на пустое view
        tableView.tableFooterView = UIView()
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
             
        } else {
            //скрываем клавиатуру при нажатии на любую ячейку (кроме первой)
            view.endEditing(true)
        }
        
    }

   
}
 //MARK: - Text field delegate
//скрываем клавиатуру по нажатию на Done
extension NewPlaceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
