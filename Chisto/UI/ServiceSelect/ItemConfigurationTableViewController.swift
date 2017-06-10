//
//  ItemConfigurationTableViewController.swift
//  Chisto
//
//  Created by Алексей on 29.04.17.
//  Copyright © 2017 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import TextFieldEffects

class ItemConfigurationTableViewController: UITableViewController {

  @IBOutlet weak var decorationSwitch: UISwitch!

  // Area section
  @IBOutlet weak var lengthField: HoshiTextField!
  @IBOutlet weak var widthField: HoshiTextField!
  @IBOutlet weak var areaLabel: UILabel!

  // Material section
  @IBOutlet weak var itemConfigurationMaterialsStackView: UIStackView!

  var viewModel: ItemConfigurationViewModel!

  enum Sections: Int {
    case material = 0
    case decoration
    case itemSize
    case additionalInfo

    static let count = 4
  }

  override func viewDidLoad() {
    lengthField.delegate = self
    widthField.delegate = self
    decorationSwitch.onTintColor = viewModel.color

    (decorationSwitch.rx.isOn <-> viewModel.hasDecoration)
      .addDisposableTo(viewModel.disposeBag)
    (lengthField.rx.text <-> viewModel.lengthText)
      .addDisposableTo(viewModel.disposeBag)
    (widthField.rx.text <-> viewModel.widthText)
      .addDisposableTo(viewModel.disposeBag)

    viewModel.areaText
      .asObservable()
      .bind(to: areaLabel.rx.text)
      .addDisposableTo(viewModel.disposeBag)
    tableView.separatorStyle = .none
    itemConfigurationMaterialsStackView.spacing = 0.5
    configureMaterialsView()
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case Sections.itemSize.rawValue:
      // TODO: refactor without the use of 0.01 value
      return viewModel.useArea ? 50 : 0.01
    default:
      return 50
    }
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    switch section {
    case Sections.decoration.rawValue:
      return super.tableView(tableView, heightForFooterInSection: section)
    default:
      return 0.01
    }
  }

  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    switch section {
    case Sections.itemSize.rawValue where !viewModel.useArea:
      view.isHidden = true
    default:
      view.isHidden = false
    }
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
    case Sections.material.rawValue:
      return CGFloat(viewModel.treatmentRowHeight)
    case Sections.itemSize.rawValue where !viewModel.useArea:
      return 0.01
    default:
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }

  func configureMaterialsView() {
    itemConfigurationMaterialsStackView.spacing = 0.5
    itemConfigurationMaterialsStackView.isHidden = true
    viewModel.treatments.asObservable()
      .filter { !$0.isEmpty }
      .subscribe(onNext: { [weak self] treatments in
      self?.resetMaterialsView(treatments: treatments)
    }).addDisposableTo(viewModel.disposeBag)
  }

  func clearMaterialsView() {
    itemConfigurationMaterialsStackView.isHidden = true
    for view in itemConfigurationMaterialsStackView.arrangedSubviews {
      itemConfigurationMaterialsStackView.removeArrangedSubview(view)
      view.removeFromSuperview()
    }
  }

  func resetMaterialsView(treatments: [Treatment]) {
    clearMaterialsView()
    for treatment in treatments {
      let view = ItemConfigurationMaterialView.nibInstance()!
      view.materialLabel.text = treatment.name
      viewModel.currentMaterial
        .asObservable()
        .map { $0 == treatment }
        .bind(to: view.isSelected)
        .addDisposableTo(view.disposeBag)

      view.itemDidTapHandler
        .map { treatment }
        .bind(to: viewModel.currentMaterial)
        .addDisposableTo(view.disposeBag)

      itemConfigurationMaterialsStackView.addArrangedSubview(view)
    }
    itemConfigurationMaterialsStackView.isHidden = false
    tableView.beginUpdates()
    tableView.endUpdates()
  }

}

extension ItemConfigurationTableViewController: UITextFieldDelegate {

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    guard let maxNumberLength = viewModel?.maxNumberLength else { return true }
    let newLength = text.characters.count + string.characters.count - range.length
    return newLength <= maxNumberLength
  }

}
