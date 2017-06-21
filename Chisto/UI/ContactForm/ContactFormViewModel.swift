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
import PassKit
import UIKit
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
  let phoneViewModel = ContactFormPhoneViewModel()

  let disposeBag = DisposeBag()

  enum CurrentScreen {
    case profile
    case orderRegistration
  }

  let contactDataHeaderModel = ContactFormTableHeaderViewModel(
    title: NSLocalizedString("contactInfo", comment: "Contact form header"),
    icon: #imageLiteral(resourceName:"iconSmallUser")
  )

  let phoneHeaderModel = ContactFormTableHeaderViewModel(
    title: NSLocalizedString("phoneHeader", comment: "Contact form header"),
    icon: #imageLiteral(resourceName: "iconSmallGrayAntenna")
  )

  let commentHeaderModel = ContactFormTableHeaderViewModel(
    title: NSLocalizedString("commentHeader", comment: "Contact form header"),
    icon: #imageLiteral(resourceName:"iconSmallComment")
  )

  let paymentHeaderModel = ContactFormTableHeaderViewModel(
    title: NSLocalizedString("paymentMethod", comment: "Contact form header"),
    icon: #imageLiteral(resourceName:"iconSmollGrayWallet")
  )

  var city: Variable<String?>
  var firstName: Variable<String?>
  var lastName: Variable<String?>
  var phone: Variable<String?>
  var code = Variable<String?>("")
  var email: Variable<String?>
  var street: Variable<String?>
  var building: Variable<String?>
  var apartment: Variable<String?>
  var comment: Variable<String?>
  var phoneIsValid = Variable<Bool>(false)
  var isValid = Variable<Bool>(false)
  var firstNameIsValid = Variable<Bool>(false)
  var cityIsValid = Variable<Bool>(true)
  var streetIsValid = Variable<Bool>(false)
  var buildingIsValid = Variable<Bool>(false)
  var apartmentIsValid = Variable<Bool>(false)
  let codeSectionIsVisible = Variable<Bool>(false)
  var paymentMethod: Variable<PaymentMethod>

  let presentErrorAlert = PublishSubject<Error>()

  var canUseApplePay = PKPaymentAuthorizationViewController.canMakePayments()
  var canPayUsingPaymentMethods = PKPaymentAuthorizationViewController.canMakePayments(
    usingNetworks: [.masterCard, .visa]
  )

  var isAuthorized: Variable<Bool> {
    return phoneViewModel.phoneIsValidated
  }

  var currentScreen: CurrentScreen

  var cityFieldDidTap = PublishSubject<Void>()
  var streetNameFieldDidTap = PublishSubject<Void>()

  let highlightPhoneField = PublishSubject<Void>()
  let highlightFirstNameField = PublishSubject<Void>()
  let highlightCityField = PublishSubject<Void>()
  let highlightStreetField = PublishSubject<Void>()
  let highlightBuildingField = PublishSubject<Void>()
  let highlightApartmentField = PublishSubject<Void>()

  init(currentScreen: CurrentScreen) {
    let profile = ProfileManager.instance.userProfile.value

    self.currentScreen = currentScreen
    self.firstName = Variable(profile.firstName)
    self.lastName = Variable(profile.lastName)
    self.phone = Variable(profile.phone)
    self.email = Variable(profile.email)
    self.city = Variable(profile.city?.name)
    self.street = Variable(profile.streetName)
    self.building = Variable(profile.building)
    self.apartment = Variable(profile.apartment)
    self.comment = Variable(profile.notes)
    self.paymentMethod = Variable(profile.paymentMethod)

    if !canPayUsingPaymentMethods && paymentMethod.value == .applePay {
      paymentMethod.value = .card
    }

    phone.asObservable()
      .map { phone in
        let phoneNumber = try? PhoneNumberKit().parse(phone ?? "")
        return phoneNumber != nil
      }.bind(to: phoneIsValid)
      .addDisposableTo(disposeBag)

    phone.asObservable()
      .bind(to: phoneViewModel.phone)
      .addDisposableTo(disposeBag)
    
    phoneViewModel.phoneIsValidated
      .asObservable()
      .map { !$0 }
      .bind(to: codeSectionIsVisible)
      .addDisposableTo(disposeBag)

    phoneViewModel.presentErrorAlert
      .bind(to: presentErrorAlert)
      .addDisposableTo(disposeBag)

    let phoneDataIsValid = Observable.combineLatest(phoneIsValid.asObservable(), phoneViewModel.phoneIsValidated.asObservable()) { $0 && $1 }

    let textFieldIsValid: (String?) -> Bool = { text in
      guard let text = text else { return false }
      return !text.characters.isEmpty
    }

    firstName.asObservable().map(textFieldIsValid).bind(to: firstNameIsValid).addDisposableTo(disposeBag)
    street.asObservable().map(textFieldIsValid).bind(to: streetIsValid).addDisposableTo(disposeBag)
    building.asObservable().map(textFieldIsValid).bind(to: buildingIsValid).addDisposableTo(disposeBag)
    apartment.asObservable().map(textFieldIsValid).bind(to: apartmentIsValid).addDisposableTo(disposeBag)


    let contactDataIsValid = Observable.combineLatest(firstNameIsValid.asObservable(), streetIsValid.asObservable(), buildingIsValid.asObservable(), apartmentIsValid.asObservable()) { $0 && $1 && $2 && $3 }

    Observable.combineLatest(contactDataIsValid, phoneDataIsValid, paymentMethod.asObservable()) { contactDataIsValid, phoneDataIsValid, paymentMethod in
      guard phoneDataIsValid else { return false }
      return contactDataIsValid || paymentMethod == .applePay
    }.bind(to: isValid).addDisposableTo(disposeBag)

  }

  func saveUserProfile() -> Observable<Void> {
    return Observable.deferred { [weak self] in
      let phoneNumberKit = PhoneNumberKit()
      let phoneNumber = try? phoneNumberKit.parse(self?.phone.value ?? "")
      let phoneError = DataError.unknown(description: NSLocalizedString("invalidPhone", comment: "Error alert"))

      guard let `self` = self else { return Observable.error(phoneError) }

      let profile = ProfileManager.instance.userProfile.value
      ProfileManager.instance.updateProfile { profile in
        if let name = self.firstName.value, name.characters.count > 0 {
          profile.firstName = name
        } else if self.paymentMethod.value == .applePay {
          profile.firstName = "Test"
        }
        profile.lastName = "Test"
        if let phoneNumber = phoneNumber {
          profile.phone = phoneNumberKit.format(phoneNumber, toType: .e164)
        }
        profile.email = "test@test.test"
        profile.streetName = self.street.value ?? ""
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

  func validateState() -> Bool {
    if !phoneIsValid.value {
      highlightPhoneField.onNext()
    }

    guard paymentMethod.value != .applePay else {
      return isValid.value
    }

    if !firstNameIsValid.value {
      highlightFirstNameField.onNext()
    }

    if !cityIsValid.value {
      highlightCityField.onNext()
    }

    if !streetIsValid.value {
      highlightStreetField.onNext()
    }

    if !buildingIsValid.value {
      highlightBuildingField.onNext()
    }

    if !apartmentIsValid.value {
      highlightApartmentField.onNext()
    }

    return isValid.value
  }

}
