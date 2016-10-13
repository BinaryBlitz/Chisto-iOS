//
//  CityNotFoundViewController.swift
//  Chisto
//
//  Created by Алексей on 12.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import EasyPeasy
import RxSwift
import RxCocoa

class CityNotFoundViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel = CityNotFoundViewModel()
    // Constants
    let titleText = "Не нашли свой город?"
    let subTitleText = "Оставьте контактные данные, и мы оповестим вас, когда наш сервис станет доступен в вашем городе"
    let cityFieldPlaceholderText = "Город"
    let phonePlaceholderText = "Телефон"
    let continueButtonText = "Продолжить"
    let cancelButtonText = "Нет, спасибо"
    
    let contentView = UIView()
    
    // Labels
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    
    // Fields
    let cityField = BottomBorderedTextField()
    let phoneField = BottomBorderedTextField()
    
    // Footer
    let footerView = UIView()
    let continueButton = UIButton()
    let separatorView = UIView()
    let cancelButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        contentView.backgroundColor = UIColor.chsWhiteTwo
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        view.addSubview(contentView)
        
        contentView <- [
            Left(15),
            CenterY(),
            Right(15)
        ]
        
        // UI
        configureHeader()
        configureBody()
        configureFooter()
        
        // Rx
        viewModel.dismissViewController.drive(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        
    }
    
    func configureHeader() {
        titleLabel.text = titleText
        titleLabel.textColor = UIColor.chsSkyBlue
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        
        contentView.addSubview(titleLabel)
        titleLabel <- [
            Top(33),
            Left(),
            Right()
        ]
        
        subTitleLabel.text = subTitleText
        subTitleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 5
        subTitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        contentView.addSubview(subTitleLabel)
        subTitleLabel <- [
            Top(30).to(titleLabel),
            Left(30),
            Right(30),
        ]

    }
    
    func configureBody() {
        cityField.borderStyle = .none
        cityField.placeholder = cityFieldPlaceholderText
        cityField.textContentType = .addressCity
        
        contentView.addSubview(cityField)
        cityField <- [
            Left(15),
            Right(15),
            Height(40),
            Top(30).to(subTitleLabel)
        ]
        
        phoneField.placeholder = phonePlaceholderText
        phoneField.textContentType = .telephoneNumber
        
        contentView.addSubview(phoneField)
        phoneField <- [
            Left(15),
            Right(15),
            Height(40),
            Top(30).to(cityField)
        ]
        
        // Rx
        cityField.rx.text.bindTo(viewModel.cityTitle).addDisposableTo(disposeBag)
        phoneField.rx.text.bindTo(viewModel.phoneTitle).addDisposableTo(disposeBag)

    }
    
    func configureFooter() {
        footerView.backgroundColor = UIColor.chsSkyBlue
        
        contentView.addSubview(footerView)
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
        
        continueButton.setTitle(continueButtonText, for: .normal)
        continueButton.titleLabel?.textColor = UIColor.white
        
        footerView.addSubview(continueButton)
        continueButton <- [
            Top().to(footerView, .top),
            Bottom().to(footerView, .bottom),
            Left().to(footerView, .left),
            Right().to(separatorView)
        ]
        
        cancelButton.setTitle(cancelButtonText, for: .normal)
        footerView.addSubview(cancelButton)
        cancelButton <- [
            Top(),
            Right(),
            Bottom(),
            Left().to(separatorView)
        ]
        
        // Rx
        continueButton.rx.tap.bindTo(viewModel.continueButtonDidTap).addDisposableTo(disposeBag)
        cancelButton.rx.tap.bindTo(viewModel.cancelButtonDidTap).addDisposableTo(disposeBag)
    }

}
