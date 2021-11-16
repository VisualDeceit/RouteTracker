//
//  UIViewControllel+nib.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import UIKit

extension UIViewController {
   func loadFromNibNamed(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
