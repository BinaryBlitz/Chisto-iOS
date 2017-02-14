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

  func configure(viewModel: OrderConfirmTableHeaderViewModel) {
    self.viewModel = viewModel
    orderPriceLabel.text = viewModel.orderPrice
    deliveryPriceLabel.text = viewModel.collectionPrice
    promoCodeButton.rx.tap.bindTo(viewModel.promoCodeButtonDidTap).addDisposableTo(disposeBag)
    viewModel.promoCodePriceDiscount.asObservable().subscribe(onNext: { [weak self] discount in
      self?.promoCodeButton.setTitle(discount, for: .normal)
      self?.promoCodeButton.titleLabel?.font = .preferredFont(forTextStyle: .callout)
      self?.promoCodeButton.isEnabled = false
      self?.promoCodeButton.contentHorizontalAlignment = .right
    }).addDisposableTo(disposeBag)
  }


}
