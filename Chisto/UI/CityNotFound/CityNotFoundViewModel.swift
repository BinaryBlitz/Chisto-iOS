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
import PhoneNumberKit

protocol CityNotFoundViewModelType {

  // Input
  var continueButtonDidTap: PublishSubject<Void> { get }
  var cancelButtonDidTap: PublishSubject<Void> { get }
  var cityTitle: Variable<String?> { get }
  var phoneTitle: Variable<String?> { get }

  // Output
  var dismissViewController: Observable<Void> { get }
  var continueButtonEnabled: Variable<Bool> { get }
  var sendData: Observable<Void> { get }

}

class CityNotFoundViewModel: CityNotFoundViewModelType {

  private let disposeBag = DisposeBag()

  // Input
  let continueButtonDidTap = PublishSubject<Void>()
  let cancelButtonDidTap = PublishSubject<Void>()
  let cityTitle: Variable<String?>
  let phoneTitle: Variable<String?>

  // Output
  let continueButtonEnabled: Variable<Bool>
  let dismissViewController: Observable<Void>
  let phoneIsValid = Variable<Bool>(false)
  let sendData: Observable<Void>

  init() {
    let cityTitle = Variable<String?>(nil)
    self.cityTitle = cityTitle
    let phoneTitle = Variable<String?>(ProfileManager.instance.userProfile.value.phone)
    self.phoneTitle = phoneTitle

    let continueButtonEnabled = Variable(false)
    self.continueButtonEnabled = continueButtonEnabled

    Observable.combineLatest(cityTitle.asObservable(), phoneIsValid.asObservable()) { cityTitle, phoneIsValid -> Bool in
      guard let cityTitle = cityTitle else { return false }
      return cityTitle.characters.count > 0 && phoneIsValid
    }.bindTo(continueButtonEnabled).addDisposableTo(disposeBag)

    sendData = continueButtonDidTap.flatMap { _ -> Observable<Void> in
      let phoneError = DataError.unknown(description: NSLocalizedString("invalidPhone", comment: "Error alert"))
      guard let phoneText = phoneTitle.value else { return Observable.error(phoneError) }
      let phoneNumberKit = PhoneNumberKit()
      guard let phoneNumber = try? phoneNumberKit.parse(phoneText) else { return Observable.error(phoneError) }
      return DataManager.instance.subscribe(cityName: cityTitle.value ?? "", phone: phoneNumberKit.format(phoneNumber, toType: .e164) )
    }.do(onNext: {
      continueButtonEnabled.value = true
    }, onSubscribe: {
      continueButtonEnabled.value = false
    })

    dismissViewController = Observable.of(sendData, cancelButtonDidTap.asObservable()).merge()

  }

}
