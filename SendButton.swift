//
//  SendButton.swift
//  Armor
//
//  Created by John on 11.06.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class SendButton : UIButton {
    
    let primaryColor =  ColorBook.apgGreen
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.accessibilityIdentifier = "SEND"
        self.setTitle(NSLocalizedString("Send button title", comment: ""), for: .normal)
        self.setTitleColor(ColorBook.apgBlack, for: .normal)
        self.titleLabel?.font = FontBook.MontserratRegular.of(size: 16)
        self.backgroundColor = primaryColor
        self.layer.cornerRadius = 15.0
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
