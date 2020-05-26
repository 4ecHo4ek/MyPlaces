//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 25.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController, UINavigationControllerDelegate {
    
    var newPlace: Place?
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        //делаем проверку что имя не пустое
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        //меняем разлиновку после наших строк ввода на пустое view
        tableView.tableFooterView = UIView()
    }
    
    //кнопка выхода из контроллера без сохранения
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == 0 {
            //добавляем фото для наших вспылвающих выбора камеры и библиотеки фото
            let cameraIcon = UIImage(systemName: "camera")
            let photoIcon = UIImage(systemName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            //не забываем запросить разрешение на использование камеры
            //в новую строку в info прописываем
            // NSCameraUsageDescription
            //в value прописываем
            // $(PRODUCT_NAME) photo use
            let camera = UIAlertAction(title: "Camera",
                                       style: .default) { _ in
                                        self.chooseImagePicker(fromSource: .camera)
            }
            //устанавливаем фото
            camera.setValue(cameraIcon, forKey: "image")
            //делаем текст слева (около иконки)
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                //self так как это уже расширение и оно вшито в класс
                self.chooseImagePicker(fromSource: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
        } else {
            //скрываем клавиатуру при нажатии на любую ячейку (кроме первой)
            view.endEditing(true)
        }
        
    }
    
    //функция сохранения данных для передачи на главный контроллер
    func saveNewPlace() {
        newPlace = Place(name: placeName.text!,
                         location: placeLocation.text,
                         type: placeType.text,
                         image: placeImage.image, restaurantImage: nil)
    }
    
    
}
//MARK: - Text field delegate
//скрываем клавиатуру по нажатию на Done
extension NewPlaceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //проверка на вкл/выкл кнопки save
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
}

//MARK: - Work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate {
    
    //это сделано без протокола (сами написали)
    func chooseImagePicker(fromSource source: UIImagePickerController.SourceType) {
        //проверяем что можно выбрать режим фотографии
        if UIImagePickerController.isSourceTypeAvailable(source) {
            //присваиваем возможность выбора фото
            let imagePicker = UIImagePickerController()
            //заставляем наш контрллер делегировать обязанности расширения (чтоб они работали)
            imagePicker.delegate = self
            //добавляем возможность редактировать фото
            imagePicker.allowsEditing = true
            //выбираем источник (тот что передадим)
            imagePicker.sourceType = source
            //выводим на экран контроллер
            present(imagePicker, animated: true, completion: nil)
        }
    }
    // до сюда сами делали
    
    //а это уже из протокола достали
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [UIImagePickerController.InfoKey : Any]) {
        //достаем фото из контроллера и присваиваем его
        placeImage.image = info[.editedImage] as? UIImage
        //меняем фотрмат фото (чтоб все место занимала, вытягивалось по имаджвью)
        placeImage.contentMode = .scaleAspectFill
        //обрезаме по границе
        placeImage.clipsToBounds = true
        //закрываем контроллер
        dismiss(animated: true, completion: nil)
    }
}
