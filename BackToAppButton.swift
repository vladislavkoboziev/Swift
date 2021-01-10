//
//  BackToAppButton.swift
//  Armor
//
//  Created by John on 28.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class BackToAppButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.accessibilityIdentifier = "backToAppButton"
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(NSLocalizedString("Back to app button label", comment: ""), for: .normal)
        self.setTitleColor(ColorBook.apgBlack, for: .normal)
        self.titleLabel?.font = FontBook.MontserratRegular.of(size: 16)
        self.backgroundColor = ColorBook.apgGreen
        self.layer.cornerRadius = 15.0
    }
    
}
