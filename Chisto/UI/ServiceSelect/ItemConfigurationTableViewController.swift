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
  @IBOutlet weak var lengthField: HoshiTextField!
  @IBOutlet weak var widthField: HoshiTextField!
  @IBOutlet weak var areaLabel: UILabel!

  var viewModel: ItemConfigurationViewModel!

  override func viewDidLoad() {
    lengthField.delegate = self
    widthField.delegate = self
    (decorationSwitch.rx.isOn <-> viewModel.hasDecoration).addDisposableTo(viewModel.disposeBag)
    (lengthField.rx.text <-> viewModel.lengthText).addDisposableTo(viewModel.disposeBag)
    (widthField.rx.text <-> viewModel.widthText).addDisposableTo(viewModel.disposeBag)
    viewModel.areaText
      .asObservable()
      .bind(to: areaLabel.rx.text)
      .addDisposableTo(viewModel.disposeBag)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.useArea ? 2 : 1
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard section == 0 else { return 0 }
    return 50
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section == 0 else { return nil }
    let view = ChistoSectionHeaderView.nibInstance()
    view?.sectionTitleLabel.text = NSLocalizedString("itemInfo", comment: "Item configuration screen")
    return view
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 20

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
