//
//  PrivacyStandbySwitch.swift
//  Armor
//
//  Created by John on 28.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class PrivacyStandbySwitch : UISwitch {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.accessibilityIdentifier = "privacyStandbySwitch"
        self.translatesAutoresizingMaskIntoConstraints = false
        self.onTintColor = ColorBook.apgBlack
        self.thumbTintColor = ColorBook.apgGray
        self.subviews[0].subviews[0].backgroundColor = ColorBook.apgBlack
        self.layer.cornerRadius = self.frame.height / 2
        self.tintColor = ColorBook.apgBlack
    }
    
}
