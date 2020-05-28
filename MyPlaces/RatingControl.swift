//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Сергей Цыганков on 28.05.2020.
//  Copyright © 2020 Сергей Цыганков. All rights reserved.
//

import UIKit


//тут будет написан рейтинг (без использования сторибоард)
class RatingControl: UIStackView {

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
    
    //MARK: - Private Methods
    //метод по доабавлению кнопок в стеквью (который мы уже разметили на сторибоард вручную!!!)
    private func setupButtons() {
        
        //create the button
        let button = UIButton()
        button.backgroundColor = .red
        
        //Add constraints
        //отключаем автосгенерированные констреинты для кнопки
        button.translatesAutoresizingMaskIntoConstraints = false
        //в двух строках определяем высоту и ширину кнопки
        button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        //Add the button to the stack
        addArrangedSubview(button)
    }
 

}
