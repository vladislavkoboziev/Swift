//
//  WhiteLabel.swift
//  Armor
//
//  Created by John on 08.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class WhiteLabel : UILabel {
    
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
    
    func setupView() {
        self.font = FontBook.MontserratRegular.of(size: 18)
        self.backgroundColor = .clear
        self.textColor = ColorBook.mainWhite
        self.lineBreakMode = .byTruncatingMiddle
        self.numberOfLines = 0
        self.textAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
