//
//  ContactDataViewModel.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ContactFormViewModelType {
  var contactInfoHeaderModel: ContactFormTableHeaderViewModel { get }
  var adressHeaderModel: ContactFormTableHeaderViewModel { get }
  var commentHeaderModel: ContactFormTableHeaderViewModel { get }
  var city: Variable<String?> { get }
  var firstName: Variable<String?> { get }
  var lastName: Variable<String?> { get }
  var phone: Variable<String?> { get }
  var email: Variable<String?> { get }
  var street: Variable<String?> { get }
  var building: Variable<String?> { get }
  var apartment: Variable<String?> { get }
  var comment: Variable<String?> { get }
}

class ContactFormViewModel {

  let disposeBag = DisposeBag()

  let contactInfoHeaderModel = ContactFormTableHeaderViewModel(title: "Контактная информация", icon: #imageLiteral(resourceName: "iconSmallUser"))
  let adressHeaderModel = ContactFormTableHeaderViewModel(title: "Адрес доставки", icon: #imageLiteral(resourceName: "iconSmallAddress"), isEnabledButton: true)
  let commentHeaderModel = ContactFormTableHeaderViewModel(title: "Комментарии к заказу", icon: #imageLiteral(resourceName: "iconSmallComment"))

  var city: Variable<String?>
  var firstName: Variable<String?>
  var lastName: Variable<String?>
  var phone: Variable<String?>
  var email: Variable<String?>
  var street: Variable<String?>
  var building: Variable<String?>
  var apartment: Variable<String?>
  var comment = Variable<String?>(nil)
  var phoneIsValid = Variable<Bool>(false)
  var isValid = Variable<Bool>(false)

  var cityFieldDidTap = PublishSubject<Void>()
  var locationHeaderButtonDidTap = PublishSubject<Void>()

  init() {
    let profile = ProfileManager.instance.userProfile
    self.firstName = Variable(profile?.firstName)
    self.lastName = Variable(profile?.lastName)
    self.phone = Variable(profile?.phone.onlyDigits)
    self.email = Variable(profile?.email)
    self.city = Variable(profile?.city?.name)
    self.street = Variable(profile?.street)
    self.building = Variable(profile?.building)
    self.apartment = Variable(profile?.apartment)

    let contactInfoIsValid = Observable.combineLatest(firstName.asObservable(), lastName.asObservable(), phoneIsValid.asObservable(), email.asObservable()) { firstName, lastName, phoneIsValid, email -> Bool in
      guard let firstName = firstName, let lastName = lastName, let email = email else { return false }

      return phoneIsValid && firstName.characters.count > 0 && lastName.characters.count > 0 && email.characters.count > 0

    }

    let adressIsValid = Observable.combineLatest(street.asObservable(), building.asObservable(), apartment.asObservable()) { street, building, apartment -> Bool in
      guard let street = street, let building = building, let apartment = apartment else { return false }
      return street.characters.count > 0 && building.characters.count > 0 && apartment.characters.count > 0

    }

    Observable.combineLatest(contactInfoIsValid, adressIsValid) { $0 && $1 }.bindTo(isValid).addDisposableTo(disposeBag)

    adressHeaderModel.buttonDidTap.asObservable().bindTo(locationHeaderButtonDidTap).addDisposableTo(disposeBag)
  }

  func saveUserProfile() {
    guard let profile = ProfileManager.instance.userProfile else { return }
    try? uiRealm.write {
      profile.firstName = firstName.value ?? ""
      profile.lastName = lastName.value ?? ""
      profile.phone = phone.value?.onlyDigits ?? ""
      profile.email = email.value ?? ""
      profile.street = street.value ?? ""
      profile.building = building.value ?? ""
      profile.apartment = apartment.value ?? ""

    }
  }

}
