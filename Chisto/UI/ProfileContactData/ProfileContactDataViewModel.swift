//
//  ProfileContactDataViewModel.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProfileContactDataViewModelType {
  // Input
  var saveButtonDidTap: PublishSubject<Void> { get }

  // Output
  var saveButtonIsEnabled: Variable<Bool> { get }
  var formViewModel: ContactFormViewModel { get }
  var presentCitySelectSection: Driver<CitySelectViewModel> { get }
  var popViewController: Driver<Void> { get }
  var cityDidSelect: PublishSubject<Void> { get }
  var presentLocationSelectSection: Driver<LocationSelectViewModel> { get }
}

class ProfileContactDataViewModel: ProfileContactDataViewModelType {

  let disposeBag = DisposeBag()
  let formViewModel: ContactFormViewModel

  let saveButtonIsEnabled = Variable(false)
  let presentCitySelectSection: Driver<CitySelectViewModel>
  let popViewController: Driver<Void>
  let saveButtonDidTap = PublishSubject<Void>()
  let cityDidSelect: PublishSubject<Void>
  let presentErrorAlert: PublishSubject<Error>
  let presentLocationSelectSection: Driver<LocationSelectViewModel>

  init() {
    let cityDidSelect = PublishSubject<Void>()
    self.cityDidSelect = cityDidSelect

    let formViewModel = ContactFormViewModel()
    self.formViewModel = formViewModel
    
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    self.presentCitySelectSection = formViewModel.cityFieldDidTap
      .asObservable()
      .map{
        let viewModel = CitySelectViewModel()

        viewModel.selectedCity.asObservable().map { $0.name }
          .bindTo(formViewModel.city)
          .addDisposableTo(viewModel.disposeBag)

        viewModel.itemDidSelect.asObservable()
          .map { _ in Void() }
          .bindTo(cityDidSelect)
          .addDisposableTo(viewModel.disposeBag)

        return viewModel
      }.asDriver(onErrorDriveWith: .empty())
    
    let saveProfileDriver = saveButtonDidTap.asObservable().flatMap {
      return formViewModel.saveUserProfile().do( onError: { error in
        presentErrorAlert.onNext(error)
      })
    }.asDriver(onErrorDriveWith: .empty())

    self.popViewController = Driver.of(cityDidSelect.asDriver(onErrorDriveWith: .empty()), saveProfileDriver).merge()

    self.presentLocationSelectSection = formViewModel.locationHeaderButtonDidTap.map {
      let viewModel = LocationSelectViewModel()
      viewModel.streetName.bindTo(formViewModel.street).addDisposableTo(viewModel.disposeBag)
      viewModel.streetNumber.bindTo(formViewModel.building).addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())

    formViewModel.isValid.asObservable().bindTo(saveButtonIsEnabled).addDisposableTo(disposeBag)
  }

}
