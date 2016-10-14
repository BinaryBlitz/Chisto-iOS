//
//  CityNotFoundViewModel.swift
//  Chisto
//
//  Created by Алексей on 13.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa
import UIKit
import CoreLocation

protocol CityNotFoundViewModelType {
  
  // Input
  var continueButtonDidTap: PublishSubject<Void> { get }
  var cancelButtonDidTap: PublishSubject<Void> { get }
  var cityTitle: ReplaySubject<String> { get }
  var phoneTitle: ReplaySubject<String> { get }
  
  // Output
  var dismissViewController: Driver<Void> { get }
  var sendData: Driver<Void> { get }
  
  var titleText: String { get }
  var subTitleText: String { get }
  var cityFieldPlaceholderText: String { get }
  var phonePlaceholderText: String { get }
  var continueButtonText: String { get }
  var cancelButtonText: String { get }

  
}

class CityNotFoundViewModel: CityNotFoundViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  var continueButtonDidTap = PublishSubject<Void>()
  var cancelButtonDidTap = PublishSubject<Void>()
  var cityTitle = ReplaySubject<String>.create(bufferSize: 1)
  var phoneTitle = ReplaySubject<String>.create(bufferSize: 1)
  
  // Output
  var dismissViewController: Driver<Void>
  var sendData: Driver<Void>
  
  // Constants
  
  let titleText = "Не нашли свой город?"
  let subTitleText = "Оставьте контактные данные, и мы оповестим вас, когда наш сервис станет доступен в вашем городе"
  let cityFieldPlaceholderText = "Город"
  let phonePlaceholderText = "Телефон"
  let continueButtonText = "Продолжить"
  let cancelButtonText = "Нет, спасибо"

  
  
  init() {
    dismissViewController = cancelButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
    // @TODO send actual data to server
    sendData = cancelButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
    
  }
  
  
}
