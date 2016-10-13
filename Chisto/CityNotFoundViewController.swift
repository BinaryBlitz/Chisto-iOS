//
//  CityNotFoundViewController.swift
//  Chisto
//
//  Created by Алексей on 12.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import EasyPeasy

class CityNotFoundViewController: UIViewController {
    // CONSTANTS
    let titleText = "Не нашли свой город?"
    let subTitleText = "Оставьте контактные данные, и мы оповестим вас, когда наш сервис станет доступен в вашем городе"
    let cityFieldPlaceholderText = "Город"
    let phonePlaceholderText = "Телефон"
    let continueButtonText = "Продолжить"
    let cancelButtonText = "Нет, спасибо"

    // LABELS
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    
    // FIELDS
    let cityField = UITextField()
    let phoneField = UITextField()
    
    //FOOTER
    let footerView = UIView()
    let continueButton = UIButton()
    let separatorView = UIView()
    let cancelButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .overFullScreen
        // TITLE LABEL
        titleLabel.text = titleText
        titleLabel.textColor = UIColor.chsSkyBlue
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        
        view.addSubview(titleLabel)
        titleLabel <- [
            Top(33),
            Left(),
            Right()
        ]
        
        subTitleLabel.text = subTitleText
        subTitleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        
        view.addSubview(subTitleLabel)
        subTitleLabel <- [
            Top(30).to(titleLabel),
            Left(30),
            Right(30)
        ]
        
        cityField.borderStyle = .line
        cityField.placeholder = cityFieldPlaceholderText
        cityField.textContentType = .addressCity
        
        view.addSubview(cityField)
        cityField <- [
            Left(15),
            Right(15),
            Top(30).to(subTitleLabel)
        ]
        
        phoneField.borderStyle = .line
        phoneField.placeholder = phonePlaceholderText
        phoneField.textContentType = .telephoneNumber
        
        view.addSubview(phoneField)
        phoneField <- [
            Left(15),
            Right(15),
            Top(30).to(cityField)
        ]
        
        footerView.backgroundColor = UIColor.chsSkyBlue
        
        view.addSubview(footerView)
        footerView <- [
            Top(30).to(phoneField),
            Height(50),
            Bottom(),
            Left(),
            Right()
        ]
        
        separatorView.backgroundColor = UIColor.chsWhite50
        
        footerView.addSubview(separatorView)
        separatorView <- [
            CenterX().to(footerView),
            Width(1),
            Top(5).to(footerView, .top),
            Bottom(5).to(footerView, .bottom)
        ]
        
        continueButton.titleLabel?.text = continueButtonText
        continueButton.titleLabel?.textColor = UIColor.white
        
        footerView.addSubview(continueButton)
        continueButton <- [
            Top().to(footerView, .top),
            Bottom().to(footerView, .bottom),
            Left().to(footerView, .left),
            Right().to(separatorView)
        ]
        
        cancelButton.titleLabel?.text = cancelButtonText
        
        footerView.addSubview(cancelButton)
        cancelButton <- [
            Top(),
            Right(),
            Bottom(),
            Left().to(separatorView)
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
