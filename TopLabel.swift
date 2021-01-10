//
//  TopLabel.swift
//  Armor
//
//  Created by John on 08.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class TopLabel : UILabel {
    
    var screenSizeType = ScreenSize()
    var fontSize : CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func labelText(text: String) {
        self.text = text
    }
    
    func labelTextColor(textColor: UIColor) {
        self.textColor = textColor
    }
    
    func setupView() {
        screenSizeType.checkParameters()
        setupFontSize()
        
        self.font = FontBook.MontserratBold.of(size: fontSize)
        self.textAlignment = .center
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupFontSize() {
        if ScreenSize.largeScreen {
            fontSize = 24.0
        } else if ScreenSize.middleScreen {
            fontSize = 20.0
        } else {
            fontSize = 16.0
        }
    }
    
}
