//
//  ProfileViewModel.swift
//  Chisto
//
//  Created by Алексей on 28.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum ProfileSection: Int {
  case contactData = 0, myOrders, aboutApp, terms
}

protocol ProfileViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var closeButtonDidTap: PublishSubject<Void> { get }

  // Output
  var dismissViewController: Driver<Void> { get }
  var presentRegistrationSection: Driver<RegistrationPhoneInputViewModel> { get }
  var ordersCount: Int { get }
}

class ProfileViewModel {

  let disposeBag = DisposeBag()
  // Input
  let itemDidSelect = PublishSubject<IndexPath>()
  let closeButtonDidTap = PublishSubject<Void>()

  // Output
  let dismissViewController: Driver<Void>
  let presentNextScreen: PublishSubject<ProfileSection>
  var presentRegistrationSection: Driver<RegistrationPhoneInputViewModel>
  var ordersCount = Variable<String>("0")

  let termsOfServiceURL = DataManager.instance.termsOfServiceURL

  init() {
    DataManager.instance.showUser().subscribe().addDisposableTo(disposeBag)
    let presentNextScreen = PublishSubject<ProfileSection>()
    self.presentNextScreen = presentNextScreen

    let newItemSectionDidTap = itemDidSelect.map { ProfileSection(rawValue: $0.section) }.filter { $0 != nil }.map { $0! }
    newItemSectionDidTap.filter { $0 == .aboutApp || $0 == .terms }.bind(to: presentNextScreen).addDisposableTo(disposeBag)

    let didTapRegistrationRequiredSectionItem = newItemSectionDidTap.filter { $0 == .myOrders || $0 == .contactData }

    didTapRegistrationRequiredSectionItem.filter { _ in ProfileManager.instance.userProfile.value.isVerified }.bind(to: presentNextScreen).addDisposableTo(disposeBag)

    let shouldPresentRegistrationSection = didTapRegistrationRequiredSectionItem.filter { _ in !ProfileManager.instance.userProfile.value.isVerified }

    self.presentRegistrationSection = shouldPresentRegistrationSection.map { nextSection in
      let viewModel = RegistrationPhoneInputViewModel()
      viewModel.didFinishRegistration.flatMap { _ -> Observable<ProfileSection> in
        return DataManager.instance.showUser().map { nextSection }
        }.bind(to: presentNextScreen).addDisposableTo(viewModel.disposeBag)
      return viewModel
      }.asDriver(onErrorDriveWith: .empty())

    self.dismissViewController = closeButtonDidTap.asDriver(onErrorDriveWith: .empty())

    self.ordersCount = Variable<String>(String(ProfileManager.instance.userProfile.value.ordersCount))
    ProfileManager.instance.userProfile.asObservable().map { String($0.ordersCount) }.bind(to: ordersCount).addDisposableTo(disposeBag)
  }

}
