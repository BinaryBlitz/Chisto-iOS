//
//  CategoriesCollectionView.swift
//  Chisto
//
//  Created by Алексей on 28.04.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources
import RxCocoa

private let reuseIdentifier = "CategoryCollectionViewCell"

class CategoriesHeaderView: UIView, UIScrollViewDelegate {
  @IBOutlet weak var collectionView: UICollectionView!

  var rxDataSource = RxCollectionViewSectionedReloadDataSource<CategoriesSectionModel>()

  var viewModel: CategoriesHeaderCollectionViewModel? = nil {
    didSet {
      configureCollectionView()
    }
  }

  func configureCollectionView() {
    guard let viewModel = viewModel else { return }

    collectionView.delegate = nil

    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

    rxDataSource.configureCell = { _, tableView, indexPath, type in
      let cell = self.collectionView.dequeueReusableCell(
        withReuseIdentifier: reuseIdentifier,
        for: indexPath
      ) as! CategoryCollectionViewCell

      cell.type = type
      return cell
    }

    collectionView.rx
      .setDelegate(self)
      .addDisposableTo(viewModel.disposeBag)

    collectionView.rx
      .itemSelected
      .bind(to: viewModel.itemDidSelect)
      .addDisposableTo(viewModel.disposeBag)

    viewModel.sections
      .drive(collectionView.rx.items(dataSource: rxDataSource))
      .addDisposableTo(viewModel.disposeBag)

  }
}
