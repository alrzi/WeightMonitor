//
//  UIView+Extension.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import UIKit

extension UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            if let stackView = self as? UIStackView {
                stackView.addArrangedSubview($0)
            } else {
                addSubview($0)
            }
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
