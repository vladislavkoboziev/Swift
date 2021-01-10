//
//  BreachesCell.swift
//  Armor
//
//  Created by John on 15.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

protocol BreachesCellDelegate: class {
    func breachesCell(cell: BreachesCell, didTappped button: UIButton)
}

class BreachesCell: UITableViewCell {
    
    var topLeftLabel : UILabel = {
        let label = UILabel()
        label.font = FontBook.MontserratRegular.of(size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bottomLeftLabel : UILabel = {
        let label = UILabel()
        label.font = FontBook.MontserratRegular.of(size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bottomRightLabel : UILabel = {
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
    
    var cellDelegate: BreachesCellDelegate?
    
    var screenSizeType = ScreenSize()
    var buttonSize : CGFloat!
    var topAnchorConstant : CGFloat!
    var middleLabelsConstant : CGFloat!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = ColorBook.apgGray
        
        screenSizeType.checkParameters()
        setupSizeParameters()
        
        addSubview(topLeftLabel)
        addSubview(bottomLeftLabel)
        addSubview(bottomRightLabel)
        addSubview(rightButton)
        
        rightButton.addTarget(self, action: #selector(BreachesCell.cellButtonAction(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            topLeftLabel.topAnchor.constraint(equalTo: topAnchor, constant: topAnchorConstant),
            topLeftLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            topLeftLabel.heightAnchor.constraint(equalToConstant: 20.0),
            topLeftLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.0),
            
            bottomLeftLabel.topAnchor.constraint(equalTo: topLeftLabel.bottomAnchor, constant: middleLabelsConstant),
            bottomLeftLabel.heightAnchor.constraint(equalToConstant: 20.0),
            bottomLeftLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            bottomLeftLabel.trailingAnchor.constraint(equalTo: bottomRightLabel.leadingAnchor),
            
            bottomRightLabel.centerYAnchor.constraint(equalTo: bottomLeftLabel.centerYAnchor),
            bottomRightLabel.heightAnchor.constraint(equalToConstant: 20.0),
            bottomRightLabel.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -5.0),
            bottomRightLabel.widthAnchor.constraint(equalToConstant: 92.0),
            
            rightButton.centerYAnchor.constraint(equalTo: bottomRightLabel.centerYAnchor),
            rightButton.heightAnchor.constraint(equalToConstant: buttonSize),
            rightButton.widthAnchor.constraint(equalToConstant: buttonSize),
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.0)
        ])
        
    }
    
    @objc func cellButtonAction(_ sender: Any) {
        cellDelegate?.breachesCell(cell: self, didTappped: sender as! UIButton)
    }
    
    func setupSizeParameters() {
        if ScreenSize.largeScreen {
            buttonSize = 40.0
            middleLabelsConstant = 25.0
            topAnchorConstant = 22.0
        } else if ScreenSize.middleScreen {
            buttonSize = 35.0
            middleLabelsConstant = 15.0
            topAnchorConstant = 9.0
        } else if ScreenSize.smallScreen {
            buttonSize = 30.0
            middleLabelsConstant = 5.0
            topAnchorConstant = 4.0
        }
    }
    
    func updateCellWith(topLeftLabelText: String, bottomLeftLabelText: String, bottomRightLabelText: String, deleteButtonTag: Int) {
        topLeftLabel.text = topLeftLabelText
        bottomLeftLabel.text = bottomLeftLabelText
        bottomRightLabel.text = bottomRightLabelText
        rightButton.tag = deleteButtonTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
