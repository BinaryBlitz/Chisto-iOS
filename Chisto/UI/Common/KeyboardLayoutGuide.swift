//
//  KeyboardLayoutGuide.swift
//  Chisto
//
//  Created by Алексей on 14.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
//
//  KeyboardLayoutGuide.swift
//  XMeetup
//
//  Created by Kirill Vilkov on 01.10.16.
//  Copyright © 2016 Kirill Vilkov. All rights reserved.
//

import UIKit
import ObjectiveC
import EasyPeasy


extension UIViewController {
    
    private struct AssociatedKey {
        static var keyboardLayoutGuide = 0
    }
    
    var keyboardLayoutGuide: UIView {
        if let view = objc_getAssociatedObject(self, &AssociatedKey.keyboardLayoutGuide) as? UIView {
            return view
        }
        let guide = UIView()
        view.addSubview(guide)
        guide <- [Bottom(), Left(), Right(), Height(0)]
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name.UIKeyboardWillChangeFrame)
            .takeUntil(self.rx.deallocating)
            .bindNext { [weak self] notification in
                let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
                guide <- Height(frame.cgRectValue.height)
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
        }
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name.UIKeyboardWillHide)
            .takeUntil(self.rx.deallocating)
            .bindNext { [weak self] notification in
                guide <- Height(0)
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
        }
        
        objc_setAssociatedObject(self, &AssociatedKey.keyboardLayoutGuide, guide, .OBJC_ASSOCIATION_RETAIN)
        
        return guide
    }
    
}
