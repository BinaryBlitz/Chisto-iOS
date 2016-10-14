//
//  OnBoardingViewController.swift
//  Chisto
//
//  Created by Алексей on 10.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import UIKit
import EasyPeasy
import RxSwift

class OnBoardingViewController: UIViewController {
  
  let descriptionSteps: [(String, UIImage)] = [
    (title: "Добавьте в список вещи, которые хотите сдать в чистку", icon: #imageLiteral(resourceName: "iconNum1")),
    (title: "Ознакомьтесь с ценой и сроками выполнения вашего заказа", icon: #imageLiteral(resourceName: "iconNum2")),
    (title: "Выберите подходящего вам исполнителя", icon: #imageLiteral(resourceName: "iconNum3")),
    (title: "Оплатите заказ удобным для вас способом", icon: #imageLiteral(resourceName: "iconNum4")),
    (title: "Ожидайте звонка. Оператор согласует время забора и доставки вещей", icon: #imageLiteral(resourceName: "iconNum5"))
  ]
  
  let descriptionLabelText = "Все очень просто:"
  let subTitleViewText = "С Chisto вам больше не нужно тратить время на походы в химчистку."
  let goButtonText = "Начать"
  
  // Header
  let headerView = UIView()
  let logoImage = UIImageView()
  let logoSubTitleView = UILabel()
  
  // Middle part
  let descriptionView = UIView()
  let descriptionLabel = UILabel()
  let descriptionListItemView = UIView()
  
  // Footer
  let goButton = UIButton()
  
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureFooter()
    configureHeader()
    configureDescription()
  }
  
  func configureDescription() {
    descriptionView.backgroundColor = UIColor.chsWhite
    descriptionView.layoutMargins = UIEdgeInsets(top: 25, left: 20, bottom: 40, right: 20)
    
    view.addSubview(descriptionView)
    descriptionView <- [
      Top().to(headerView),
      Left(),
      Right(),
      Bottom().to(goButton)
    ]
    
    descriptionLabel.text = descriptionLabelText
    descriptionLabel.textAlignment = .center
    descriptionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    
    descriptionView.addSubview(descriptionLabel)
    
    descriptionLabel <- [
      Top().to(descriptionView, .topMargin),
      LeftMargin(),
      RightMargin()
    ]
    
    let stackView = UIStackView()
    stackView.distribution = .fillEqually
    stackView.spacing = 20
    stackView.axis = .vertical
    
    descriptionView.addSubview(stackView)
    stackView <- [
      Top(20).to(descriptionLabel, .bottom),
      Left().to(descriptionView, .leftMargin),
      Right().to(descriptionView, .rightMargin),
      Bottom().to(descriptionView, .bottomMargin)
    ]
    
    for (title, icon) in descriptionSteps {
      let view = DescriptionListItemView(countImage: icon, information: title)
      descriptionView.addSubview(view)
      stackView.addArrangedSubview(view)
      
    }
    
  }
  
  func configureHeader() {
    headerView.backgroundColor = UIColor.chsSkyBlue
    headerView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    view.addSubview(headerView)
    
    headerView <- [
      Top(),
      Left(),
      Right()
    ]
    
    logoImage.image = #imageLiteral(resourceName: "logoWhite")
    logoImage.contentMode = .scaleAspectFit
    
    headerView.addSubview(logoImage)
    
    logoImage <- [
      CenterX().to(headerView),
      Top(50).to(headerView)
    ]
    
    logoSubTitleView.textColor = UIColor.white
    
    logoSubTitleView.text = subTitleViewText
    logoSubTitleView.font = UIFont.preferredFont(forTextStyle: .subheadline)
    logoSubTitleView.textAlignment = .center
    logoSubTitleView.numberOfLines = 3
    
    headerView.addSubview(logoSubTitleView)
    
    logoSubTitleView <- [
      Left().to(headerView, .leftMargin),
      Right().to(headerView, .rightMargin),
      Top(20).to(logoImage),
      Bottom(20).to(headerView, .bottomMargin)
    ]
    
  }
  
  func configureFooter() {
    view.addSubview(goButton)
    
    goButton.backgroundColor = UIColor.chsSkyBlue
    
    goButton.titleLabel?.textColor = UIColor.white
    goButton.setTitle(goButtonText, for: .normal)
    goButton.rx.tap.asDriver().drive(onNext: {
      self.navigationController?.pushViewController(CitySelectTableViewController(), animated: true)
      }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    
    goButton <- [
      Bottom().to(view, .bottom),
      Left(),
      Right(),
      Height(50)
    ]
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
}
