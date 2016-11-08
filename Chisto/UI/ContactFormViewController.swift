//
//  ContactDataViewController.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import TextFieldEffects

class ContactFormViewController: UITableViewController {
  var viewModel: ContactFormViewModel? = nil
  
  @IBOutlet weak var firstNameField: HoshiTextField!
  @IBOutlet weak var lastNameField: HoshiTextField!
  @IBOutlet weak var phoneField: HoshiTextField!
  @IBOutlet weak var cityField: HoshiTextField!
  @IBOutlet weak var streetField: HoshiTextField!
  @IBOutlet weak var houseField: HoshiTextField!
  @IBOutlet weak var commentField: HoshiTextField!
  
  let contactInfoHeaderView = ContactFormTableHeaderView.nibInstance()!
  let adressHeaderView = ContactFormTableHeaderView.nibInstance()!
  let commentHeaderView = ContactFormTableHeaderView.nibInstance()!
  
  let maskedPhoneInput = MaskedInput(formattingPattern: "+* (***) *** ∙ ** ∙ **", replacementChar: "*")
  
  enum Sections: Int {
    case contactInfo = 0
    case adress
    case comment
  }
  
  override func viewDidLoad() {
    maskedPhoneInput.configure(textField: phoneField)
    configureSections()
  }
  
  func configureSections() {
    guard let viewModel = viewModel else { return }
    
    contactInfoHeaderView.configure(viewModel: viewModel.contactInfoHeaderModel)
    adressHeaderView.configure(viewModel: viewModel.adressHeaderModel)
    commentHeaderView.configure(viewModel: viewModel.commentHeaderModel)
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case Sections.contactInfo.rawValue:
      return contactInfoHeaderView
    case Sections.adress.rawValue:
      return adressHeaderView
    case Sections.comment.rawValue:
      return commentHeaderView
    default:
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  
}
