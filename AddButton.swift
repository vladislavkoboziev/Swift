//
//  AddButton.swift
//  Armor
//
//  Created by John on 21.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class AddButton : UIButton {
    
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
        self.accessibilityIdentifier = "ADD"
        self.setTitle(NSLocalizedString("Add button title", comment: ""), for: .normal)
        self.setTitleColor(ColorBook.apgBlack, for: .normal)
        self.titleLabel?.font = FontBook.MontserratRegular.of(size: 16)
        self.backgroundColor = primaryColor
        self.layer.cornerRadius = 15.0
    }
    
}
