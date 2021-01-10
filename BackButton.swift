//
//  BackButton.swift
//  Armor
//
//  Created by John on 21.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class BackButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.accessibilityIdentifier = "backButton"
        self.setImage(UIImage(named: "back_button_icon"), for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
