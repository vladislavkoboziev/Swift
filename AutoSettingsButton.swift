//
//  AutoSettingsButton.swift
//  Armor
//
//  Created by John on 08.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class AutoSettingsButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    func setupView() {
        let buttonIsEnabledImage = UIImage(named: "auto_button_enabled.png")
        let buttonIsDisabledImage = UIImage(named: "auto_button_disabled.png")
        self.setImage(buttonIsDisabledImage, for: .normal)
        self.setImage(buttonIsEnabledImage, for: .selected)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
}
