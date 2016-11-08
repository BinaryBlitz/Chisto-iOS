//
//  ContactDataViewModel.swift
//  Chisto
//
//  Created by Алексей on 08.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation

class ContactFormViewModel {
  let contactInfoHeaderModel = ContactFormTableHeaderViewModel(title: "Контактная информация", icon: #imageLiteral(resourceName: "iconSmallUser"))
  let adressHeaderModel = ContactFormTableHeaderViewModel(title: "Адрес доставки", icon: #imageLiteral(resourceName: "iconSmallAddress"))
  let commentHeaderModel = ContactFormTableHeaderViewModel(title: "Комментарии к заказу", icon: #imageLiteral(resourceName: "iconSmallComment"))
}
