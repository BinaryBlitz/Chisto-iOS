//
//  OnBoardingViewModel.swift
//  Chisto
//
//  Created by Алексей on 09.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol OnBoardingViewModelType {
  var goButtonDidTap: PublishSubject<Void> { get }
  
  var presentCitySelectSection: Driver<CitySelectViewModel> { get }
  var dismissViewController: Driver<Void> { get }
}

class OnBoardingViewModel {
  var goButtonDidTap = PublishSubject<Void>()
  var cityDidSelected: PublishSubject<Void>
  
  var presentCitySelectSection: Driver<CitySelectViewModel>
  var dismissViewController: Driver<Void>
  
  init() {
    let cityDidSelected = PublishSubject<Void>()
    self.cityDidSelected = cityDidSelected
    self.dismissViewController = cityDidSelected.asDriver(onErrorDriveWith: .empty())
    
    self.presentCitySelectSection = goButtonDidTap.asObservable().map {
      let viewModel = CitySelectViewModel()
      viewModel.itemDidSelect.asObservable().map{ _ in Void() }
        .bindTo(cityDidSelected)
        .addDisposableTo(viewModel.disposeBag)
      return viewModel
    }.asDriver(onErrorDriveWith: .empty())
  }
}
