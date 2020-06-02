//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 28.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit


//тут будет написан рейтинг (без использования сторибоард)
//данная приписка с @ позволяет отобразить все измененияв коде в интерфейсбилдере
@IBDesignable class RatingControl: UIStackView {
    
    //MARK: - Properties
    
    private var ratingButtons = [UIButton]()
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    //свойства для настройки их свойст в интерфейсбилдере (без этих надписей, редактировать в  нем нельзя будет
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        //это мы прописываем чтоб иметь возможность редактировать эти параметры непосредственно в интерфейсбилдере, без них, поля созданные ранее будут неактивны)
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: - Initialization
    //инициализания на сторибоарде
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    //инициализотор в коде
    //данный инииализатор будет обязателен во всех дочерних классах
    //все остальные будут авториализоовываться
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: - Button Action
    //тут прописывается логика нажатия на кнопку
    @objc func ratingButtonTapped(button: UIButton) {
        
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        //Calculate the rating of the selected button
        let selectedRating = index + 1
        //если выбран рейтинг, который уже был ранее выбран, то он (внутренняя переменная) обнулиться, чтоб не менять изображение рейтинга
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        
        
    }
    
    
    //MARK: - Private Methods
    //метод по доабавлению кнопок в стеквью (который мы уже разметили на сторибоард вручную!!!)
    private func setupButtons() {
        //метод по удалению уже существущих кнопок (чтоб при изменении кол-ва через интерфейсбилдер они не наслаивались друг на друга)
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        //очищаем массив кнопок
        ratingButtons.removeAll()
        
        //этот метод нужен для того, чтоб мы могли наши изображения видеть в интерфейс билдере, так как они не системные, до них необходимо указать путь, а затем уже выбирать какое изображение откуда берется
        let bundle = Bundle(for: type(of: self))
        //Load button image
        //крайнее свойство служит для проверки того, что мы верно загрузили объект
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle,
                                 compatibleWith: self.traitCollection)
        
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        let highlightedStar = UIImage(named: "highlightedStar",
                                      in: bundle,
                                      compatibleWith: self.traitCollection)
        
        for _ in 1...starCount {
            
            //create the button
            let button = UIButton()
           
            //Set the button image
            //normal - когда кнопка не нажата и не выделена, не отключина и тд, тоесть просто есть
            button.setImage(emptyStar, for: .normal)
            //такое состояние задается только программно
            button.setImage(filledStar, for: .selected)
            //это при прикосновении к ней
            button.setImage(highlightedStar, for: .highlighted)
            //и то и другое что выше
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            
            //Add constraints
            //отключаем автосгенерированные констреинты для кнопки
            button.translatesAutoresizingMaskIntoConstraints = false
            //в двух строках определяем высоту и ширину кнопки
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            //Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
            
            
            //Add the button to the stack
            addArrangedSubview(button)
            
            //Add the new button on the tating Button Array
            ratingButtons.append(button)
        }
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState() {
        //enumerate возвращает пару - номер и сам объект
        for (index, button) in ratingButtons.enumerated() {
            //если рейтинг меньше индекса. то будет присваиваться true и кнопка окраситься
            button.isSelected = index < rating
        }
    }
    
}
