//
//  ProfileContainerViewModel.swift
//  Chisto
//
//  Created by Алексей on 20.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileContainerViewModel {
  let disposeBag = DisposeBag()
  let logoutButtonDidTap = PublishSubject<Void>()
  let navigationCloseButtonDidTap = PublishSubject<Void>()
  let dismissViewController: Driver<Void>
  let presentOnboardingScreen: Driver<Void>
  let buttonIsHidden: Variable<Bool>

  init() {
    self.dismissViewController = navigationCloseButtonDidTap.asDriver(onErrorDriveWith: .empty())
    self.presentOnboardingScreen = logoutButtonDidTap.asDriver(onErrorDriveWith: .empty()).map {
      ProfileManager.instance.logout()
    }
    self.buttonIsHidden = Variable(ProfileManager.instance.userProfile.value.apiToken != nil)
    ProfileManager.instance.userProfile.asObservable().map { $0.apiToken == nil }.bind(to: buttonIsHidden).addDisposableTo(disposeBag)
  }
}
