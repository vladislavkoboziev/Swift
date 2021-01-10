//
//  InformationButton.swift
//  Armor
//
//  Created by John on 08.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class InformationButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.accessibilityIdentifier = "informationButton"
        self.setImage(UIImage(named: "info_button_icon"), for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
