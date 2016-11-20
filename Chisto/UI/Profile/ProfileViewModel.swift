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

enum ProfileSections: Int {
  case contactData = 0, myOrders, aboutApp, rules
}

protocol ProfileViewModelType {
  // Input
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var closeButtonDidTap: PublishSubject<Void> { get }

  // Output
  var presentAboutSection: Driver<Void> { get }
  var presentContactDataSection: Driver<Void> { get }
  var presentMyOrdersSection: Driver<Void> { get }
  var dismissViewController: Driver<Void> { get }
  var ordersCount: Int { get }
}

class ProfileViewModel {
  let disposeBag = DisposeBag()
  // Input
  let itemDidSelect = PublishSubject<IndexPath>()
  let closeButtonDidTap = PublishSubject<Void>()

  // Output
  let presentAboutSection: Driver<Void>
  let presentContactDataSection: Driver<Void>
  let presentMyOrdersSection: Driver<Void>
  let dismissViewController: Driver<Void>
  var ordersCount = Variable<String>("0")

  init() {
    self.presentAboutSection = itemDidSelect.filter { $0.section == ProfileSections.aboutApp.rawValue }.map{_ in Void()}.asDriver(onErrorDriveWith: .empty())
    
    self.presentContactDataSection = itemDidSelect.filter { $0.section == ProfileSections.contactData.rawValue }.map{_ in Void()}.asDriver(onErrorDriveWith: .empty())
    
    self.presentMyOrdersSection = itemDidSelect.filter { $0.section == ProfileSections.myOrders.rawValue }.map{_ in Void()}.asDriver(onErrorDriveWith: .empty())

    self.dismissViewController = closeButtonDidTap.asDriver(onErrorDriveWith: .empty())
    
    Observable.from(uiRealm.objects(Order.self))
      .map { String($0.count) }
      .bindTo(ordersCount)
      .addDisposableTo(disposeBag)
  }

}
