//
//  TutorialButton.swift
//  Armor
//
//  Created by John on 13.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class TutorialButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    func setupView() {
        self.accessibilityIdentifier = "tutorialButton"
        self.setImage(UIImage(named: "play_circle_button_icon"), for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
}
