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
  @IBOutlet weak var clothLabel: UILabel!
  @IBOutlet weak var clothIconView: UIImageView!
  @IBOutlet weak var leatherLabel: UILabel!
  @IBOutlet weak var leatherIconView: UIImageView!

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

    viewModel.currentMaterial.asObservable().subscribe(onNext: { [weak self] material in
      self?.clothLabel.isHighlighted = material == .cloth
      self?.clothIconView.isHighlighted = material == .cloth
      self?.leatherLabel.isHighlighted = material == .leather
      self?.leatherIconView.isHighlighted = material == .leather
    }).addDisposableTo(viewModel.disposeBag)
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
    case Sections.itemSize.rawValue where !viewModel.useArea:
      return 0.01
    default:
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case Sections.material.rawValue:
      viewModel.currentMaterial.value = indexPath.row == 0 ? .cloth : .leather
    default:
      break
    }
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
