//
//  BreachedEmailsCell.swift
//  Armor
//
//  Created by John on 15.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

protocol BreachedEmailsCellDelegate: class {
    func breachedEmailsCell(cell: BreachedEmailsCell, didTappped button: UIButton)
}

class BreachedEmailsCell: UITableViewCell {
    
    var leftLabel : UILabel = {
        let label = UILabel()
        label.font = FontBook.MontserratRegular.of(size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var rightButton : UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "Delete"
        button.setImage(UIImage(named: "delete_button_icon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var cellDelegate: BreachedEmailsCellDelegate?
    
    var screenSizeType = ScreenSize()
    var buttonSize : CGFloat!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = ColorBook.apgGray
        
        screenSizeType.checkParameters()
        setupSizeParameters()
        
        addSubview(leftLabel)
        addSubview(rightButton)
        
        rightButton.addTarget(self, action: #selector(BreachesCell.cellButtonAction(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            leftLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            
            rightButton.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor),
            rightButton.heightAnchor.constraint(equalToConstant: buttonSize),
            rightButton.widthAnchor.constraint(equalToConstant: buttonSize),
            rightButton.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: -15.0),
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.0)
        ])
        
    }
    
    @objc func cellButtonAction(_ sender: Any) {
        cellDelegate?.breachedEmailsCell(cell: self, didTappped: sender as! UIButton)
    }
    
    func setupSizeParameters() {
        if ScreenSize.largeScreen {
            buttonSize = 40.0
        } else if ScreenSize.middleScreen {
            buttonSize = 35.0
        } else if ScreenSize.smallScreen {
            buttonSize = 30.0
        }
    }
    
    func updateCellWith(leftLabelText: String, deleteButtonTag: Int) {
        leftLabel.text = leftLabelText
        rightButton.tag = deleteButtonTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
