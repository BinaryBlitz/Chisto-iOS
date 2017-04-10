//
//  OrderInfoTableHeaderView.swift
//  Chisto
//
//  Created by Алексей on 22.01.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OrderInfoTableHeaderView: UIView {
  let disposeBag = DisposeBag()
  @IBOutlet weak var laundryLogoView: UIImageView!
  @IBOutlet weak var laundryTitleLabel: UILabel!
  @IBOutlet weak var laundryDescriptionLabel: UILabel!
  @IBOutlet weak var orderStatusLabel: UILabel!
  @IBOutlet weak var orderStatusImageView: UIImageView!
  @IBOutlet weak var paymentMethodLabel: UILabel!
  @IBOutlet weak var paymentMethodImageView: UIImageView!
  @IBOutlet weak var orderDateLabel: UILabel!
  @IBOutlet weak var orderPromoCodeLabel: UILabel!
  @IBOutlet weak var orderPromoCodeDiscountLabel: UILabel!
  @IBOutlet weak var orderPriceLabel: UILabel!
  @IBOutlet weak var deliveryPriceLabel: UILabel!
  @IBOutlet weak var orderTotalPriceLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var promoCodeView: UIView!
  @IBOutlet weak var promoCodeDiscountView: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  func configure(viewModel: OrderInfoTableHeaderViewModel) {
    viewModel.orderPrice.asObservable().bind(to: orderPriceLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.deliveryPrice.asObservable().bind(to: deliveryPriceLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.totalprice.asObservable().bind(to: orderTotalPriceLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.promoCodeText.asObservable().bind(to: orderPromoCodeLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.promoCodeDiscount.asObservable().bind(to: orderPromoCodeDiscountLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.paymentMethodImage.asObservable().bind(to: paymentMethodImageView.rx.image).addDisposableTo(disposeBag)
    viewModel.paymentType.asObservable().bind(to: paymentMethodLabel.rx.text).addDisposableTo(disposeBag)

    viewModel.promoCode.asObservable().subscribe(onNext: { [weak self] promoCode in
        self?.promoCodeView.isHidden = promoCode == nil
        self?.promoCodeDiscountView.isHidden = promoCode == nil
        self?.viewController()?.view.layoutIfNeeded()
      }).addDisposableTo(disposeBag)


    bindLaundryData(viewModel: viewModel)
    bindLaundryStatusData(viewModel: viewModel)

  }

  func bindLaundryData(viewModel: OrderInfoTableHeaderViewModel) {
    viewModel.laundryIcon.asObservable().subscribe(onNext: { [weak self] icon in
        self?.laundryLogoView.kf.setImage(with: icon)
      }).addDisposableTo(disposeBag)
    viewModel.laundryTitle.asObservable().bind(to: laundryTitleLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.laundryDescriprion.asObservable().bind(to: laundryDescriptionLabel.rx.text).addDisposableTo(disposeBag)

    viewModel.laundryDescriprion.asObservable().subscribe(onNext: { [weak self] _ in
        self?.viewController()?.view.layoutIfNeeded()
      }).addDisposableTo(disposeBag)

  }

  func bindLaundryStatusData(viewModel: OrderInfoTableHeaderViewModel) {
    viewModel.orderStatus.asObservable().bind(to: orderStatusLabel.rx.text).addDisposableTo(disposeBag)
    viewModel.orderDate.asObservable().bind(to: orderDateLabel.rx.text).addDisposableTo(disposeBag)

    viewModel.orderStatusIcon.asObservable().filter { $0 != nil }.map { $0! }
      .bind(to: orderStatusImageView.rx.image).addDisposableTo(disposeBag)

    viewModel.orderStatusColor.asObservable().subscribe(onNext: { [weak self] color in
        self?.orderStatusLabel.textColor = color
      }).addDisposableTo(disposeBag)

  }

}
