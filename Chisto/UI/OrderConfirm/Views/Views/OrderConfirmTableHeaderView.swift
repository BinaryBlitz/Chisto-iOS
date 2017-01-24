//
//  OrderConfirmTableHeaderView.swift
//  Chisto
//
//  Created by Алексей on 20.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import FloatRatingView
import RxSwift
import RxCocoa
import Kingfisher

class OrderConfirmTableHeaderView: UIView {
  let disposeBag = DisposeBag()
  var viewModel: OrderConfirmTableHeaderViewModel? = nil
  @IBOutlet weak var orderPriceLabel: UILabel!
  @IBOutlet weak var deliveryPriceLabel: UILabel!
  @IBOutlet weak var promoCodeButton: UIButton!
  @IBOutlet weak var laundryBackgroundImageView: UIImageView!
  @IBOutlet weak var laundryLogoImageView: UIImageView!
  @IBOutlet weak var laundryDecriptionLabel: UILabel!
  @IBOutlet weak var laundryRatingsCountLabel: UILabel!
  @IBOutlet weak var laundryRatingView: FloatRatingView!
  @IBOutlet weak var collectionDateLabel: UILabel!
  @IBOutlet weak var collectionTimeLabel: UILabel!
  @IBOutlet weak var deliveryDateLabel: UILabel!
  @IBOutlet weak var deliveryTimeLabel: UILabel!

  func configure(viewModel: OrderConfirmTableHeaderViewModel) {
    self.viewModel = viewModel
    laundryDecriptionLabel.text = viewModel.laundryDescriprionTitle
    laundryLogoImageView.kf.setImage(with: viewModel.laundryIcon)
    collectionTimeLabel.text = viewModel.collectionTime
    deliveryTimeLabel.text = viewModel.deliveryTime
    laundryRatingView.rating = viewModel.laundryRating 
    laundryRatingsCountLabel.text = viewModel.ratingsCountText
    collectionDateLabel.text = viewModel.collectionDate
    orderPriceLabel.text = viewModel.orderPrice
    deliveryDateLabel.text = viewModel.deliveryDate
    deliveryPriceLabel.text = viewModel.collectionPrice

    let backgroundProcessor = OverlayImageProcessor(overlay: .black, fraction: 0.7)
    laundryBackgroundImageView.kf.setImage(with: viewModel.laundryBackground, options: [.processor(backgroundProcessor)])
    promoCodeButton.rx.tap.bindTo(viewModel.promoCodeButtonDidTap).addDisposableTo(disposeBag)
    viewModel.promoCode.asObservable().filter { $0 != nil }.subscribe(onNext: { [weak self] code in
      guard let code = code, code.characters.count > 0 else { return }
      self?.promoCodeButton.setTitle("-760 ₽", for: .normal)
      self?.promoCodeButton.titleLabel?.font = .systemFont(ofSize: 16)
      self?.promoCodeButton.isEnabled = false
      self?.promoCodeButton.contentHorizontalAlignment = .right
    }).addDisposableTo(disposeBag)
  }


  @IBAction func headerViewDidTap(_ sender: Any) {
    viewModel?.headerViewDidTap.onNext()
  }


}
