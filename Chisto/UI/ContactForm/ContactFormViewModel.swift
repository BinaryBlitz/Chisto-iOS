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
import PhoneNumberKit

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
  var paymentMethod: Variable<PaymentMethod> { get }
}

class ContactFormViewModel {

  let disposeBag = DisposeBag()

  enum CurrentScreen {
    case profile
    case orderRegistration
  }

  let contactInfoHeaderModel = ContactFormTableHeaderViewModel(title: NSLocalizedString("contactInfo", comment: "Contact form header"), icon: #imageLiteral(resourceName: "iconSmallUser"))
  let adressHeaderModel = ContactFormTableHeaderViewModel(title: NSLocalizedString("deliveryAdress", comment: "Contact form header"), icon: #imageLiteral(resourceName: "iconSmallAddress"), isEnabledButton: true)
  let commentHeaderModel = ContactFormTableHeaderViewModel(title: NSLocalizedString("orderComments", comment: "Contact form header"), icon: #imageLiteral(resourceName: "iconSmallComment"))
  let paymentHeaderModel = ContactFormTableHeaderViewModel(title: NSLocalizedString("paymentMethod", comment: "Contact form header"), icon: #imageLiteral(resourceName: "iconSmollGrayWallet"))

  var city: Variable<String?>
  var firstName: Variable<String?>
  var lastName: Variable<String?>
  var phone: Variable<String?>
  var email: Variable<String?>
  var street: Variable<String?>
  var building: Variable<String?>
  var apartment: Variable<String?>
  var comment: Variable<String?>
  var phoneIsValid = Variable<Bool>(false)
  var isValid = Variable<Bool>(false)
  var paymentMethod: Variable<PaymentMethod>

  var currentScreen: CurrentScreen

  var cityFieldDidTap = PublishSubject<Void>()
  var streetNameFieldDidTap = PublishSubject<Void>()

  init(currentScreen: CurrentScreen) {
    self.currentScreen = currentScreen
    let profile = ProfileManager.instance.userProfile.value
    self.firstName = Variable(profile.firstName)
    self.lastName = Variable(profile.lastName)
    self.phone = Variable(profile.phone)
    self.email = Variable(profile.email)
    self.city = Variable(profile.city?.name)
    self.street = Variable(profile.street)
    self.building = Variable(profile.building)
    self.apartment = Variable(profile.apartment)
    self.comment = Variable(profile.notes)
    self.paymentMethod = Variable(profile.paymentMethod)

    let contactInfoIsValid = Observable.combineLatest(firstName.asObservable(), lastName.asObservable(), phoneIsValid.asObservable(), email.asObservable()) { firstName, lastName, phoneIsValid, email -> Bool in
      guard let firstName = firstName, let lastName = lastName, let email = email else { return false }

      return phoneIsValid && firstName.characters.count > 0 && lastName.characters.count > 0 && email.characters.count > 0

    }

    let adressIsValid = Observable.combineLatest(street.asObservable(), building.asObservable(), apartment.asObservable()) { street, building, apartment -> Bool in
      guard let street = street, let building = building, let apartment = apartment else { return false }
      return street.characters.count > 0 && building.characters.count > 0 && apartment.characters.count > 0

    }

    Observable.combineLatest(contactInfoIsValid, adressIsValid) { $0 && $1 }.bindTo(isValid).addDisposableTo(disposeBag)

  }


  func saveUserProfile() -> Observable<Void> {
    return Observable.deferred { [weak self] in
      let phoneNumberKit = PhoneNumberKit()
      let phoneNumber = try? phoneNumberKit.parse(self?.phone.value ?? "")
      let phoneError = DataError.unknown(description: NSLocalizedString("invalidPhone", comment: "Profile screen"))

      guard let `self` = self else { return Observable.error(phoneError) }

      let profile = ProfileManager.instance.userProfile.value
      ProfileManager.instance.updateProfile { profile in
        profile.firstName = self.firstName.value ?? ""
        profile.lastName = self.lastName.value ?? ""
        if let phoneNumber = phoneNumber {
          profile.phone = phoneNumberKit.format(phoneNumber, toType: .e164)
        }
        profile.email = self.email.value ?? ""
        profile.street = self.street.value ?? ""
        profile.building = self.building.value ?? ""
        profile.apartment = self.apartment.value ?? ""
        profile.notes = self.comment.value ?? ""
        profile.paymentMethod = self.paymentMethod.value
      }
      if profile.isCreated {
        return DataManager.instance.updateUser()
      } else {
        return DataManager.instance.createUser()
      }
    }
    
  }

}
