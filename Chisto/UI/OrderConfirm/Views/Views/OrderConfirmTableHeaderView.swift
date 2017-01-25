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
