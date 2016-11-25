//
//  LaundryReviewsViewModel.swift
//  Chisto
//
//  Created by Алексей on 18.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa

typealias LaundryReviewsSectionModel = SectionModel<String, LaundryReviewsViewTableViewCellModelType>

protocol LaundryReviewsViewModelType {
  var sections: Driver<[LaundryReviewsSectionModel]> { get }
  var ratings: Variable<[Rating]> { get }
  var laundryBackgroundUrl: URL? { get }
  var laundryLogoUrl: URL? { get }
  var laundryTitle: String { get }
  var laundryRating: Float { get }
  var laundryReviewsCountLabel: String { get }
}

class LaundryReviewsViewModel: LaundryReviewsViewModelType {
  let disposeBag = DisposeBag()
  let sections: Driver<[LaundryReviewsSectionModel]>
  let presentErrorAlert: PublishSubject<Error>
  let ratings: Variable<[Rating]>
  let laundryBackgroundUrl: URL?
  let laundryLogoUrl: URL?
  let laundryTitle: String
  let laundryRating: Float
  let laundryReviewsCountLabel: String
  let ratingCountLabels = ["отзыв", "отзыва", "отзывов"]

  init(laundry: Laundry) {
    
    let ratings = Variable<[Rating]>([])
    self.ratings = ratings
    
    let presentErrorAlert = PublishSubject<Error>()
    self.presentErrorAlert = presentErrorAlert

    DataManager.instance.fetchRatings(laundry: laundry).do(onError: { error in
      presentErrorAlert.onNext(error)
    }).bindTo(ratings).addDisposableTo(disposeBag)
    
    self.laundryTitle = laundry.name
    self.laundryRating = laundry.rating
    self.laundryLogoUrl = URL(string: laundry.logoUrl)
    self.laundryBackgroundUrl = URL(string: laundry.backgroundImageUrl)
    
    self.laundryReviewsCountLabel = "\(ratings.value.count) " + getRussianNumEnding(number: ratings.value.count, endings: ratingCountLabels)
    
    self.sections = ratings.asDriver().map { ratings in
      let cellModels = ratings.map(LaundryReviewsViewTableViewCellModel.init) as [LaundryReviewsViewTableViewCellModelType]
      
      let section = LaundryReviewsSectionModel(model: "", items: cellModels)
      return [section]
    }

  }
}
