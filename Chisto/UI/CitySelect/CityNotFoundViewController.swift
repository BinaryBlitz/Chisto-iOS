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
  let animationDuration = 0.3
  
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
    hideKeyboardWhenTappedAround()
    
    self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    
    let avaliableView = UIView()
    view.addSubview(avaliableView)
    
    avaliableView <- [
      Left(),
      Right(),
      Top().to(topLayoutGuide),
      Bottom().to(keyboardLayoutGuide)
    ]
    
    contentView.backgroundColor = UIColor.chsWhiteTwo
    contentView.layer.cornerRadius = 8
    contentView.clipsToBounds = true
    
    avaliableView.addSubview(contentView)
    
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
      UIView.animate(withDuration: self?.animationDuration ?? 0, animations: {
        self?.view.alpha = 0
        }, completion: { _ in
          self?.dismiss(animated: false, completion: nil)
      })
      }).addDisposableTo(disposeBag)
    
  }
  
  func configureHeader() {
    titleLabel.text = viewModel.titleText
    titleLabel.textColor = UIColor.chsSkyBlue
    titleLabel.textAlignment = .center
    titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
    
    contentView.addSubview(titleLabel)
    titleLabel <- [
      Top(33),
      Left(),
      Right()
    ]
    
    subTitleLabel.text = viewModel.subTitleText
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
    cityField.placeholder = viewModel.cityFieldPlaceholderText
    if #available(iOS 10.0, *) {
      cityField.textContentType = .addressCity
    } else {
      // Fallback on earlier versions
    }
    
    contentView.addSubview(cityField)
    cityField <- [
      Left(15),
      Right(15),
      Height(40),
      Top(30).to(subTitleLabel)
    ]

    phoneField.placeholder = viewModel.phonePlaceholderText
    if #available(iOS 10.0, *) {
      phoneField.textContentType = .telephoneNumber
    } else {
      // Fallback on earlier versions
    }
    
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
    
    continueButton.setTitle(viewModel.continueButtonText, for: .normal)
    continueButton.titleLabel?.textColor = UIColor.white
    
    footerView.addSubview(continueButton)
    continueButton <- [
      Top().to(footerView, .top),
      Bottom().to(footerView, .bottom),
      Left().to(footerView, .left),
      Right().to(separatorView)
    ]
    
    cancelButton.setTitle(viewModel.cancelButtonText, for: .normal)
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
  
  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.alpha = 0
      self?.view.alpha = 1
    }
  }
  
}
