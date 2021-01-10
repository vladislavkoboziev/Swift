//
//  PrivacyCell.swift
//  Armor
//
//  Created by John on 13.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

protocol PrivacyCellDelegate: class {
    func privacyCell(cell: PrivacyCell, didTappped button: UIButton)
}

class PrivacyCell: UITableViewCell {
    
    let cellAutoButton = AutoSettingsButton()
    
    let cellICharLabel: UILabel = {
        let label = UILabel()
        label.text = " \u{24D8}"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorBook.apgLightGray
        
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    let cellTutorialButton = TutorialButton()
    
    var cellTitleLabel : UILabel = {
        let label = UILabel()
        label.textColor = ColorBook.apgLightGray
        label.font = FontBook.MontserratRegular.of(size: 16)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        return label
    }()
    
    let cellSettingLabel = PrivacyCellLabel()
    
    var cellDelegate: PrivacyCellDelegate?
    
    var screenSizeType = ScreenSize()
    var buttonWidth : CGFloat!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        screenSizeType.checkParameters()
        setupButtonsParameters()
        
        addSubview(cellTitleLabel)
        addSubview(cellICharLabel)
        addSubview(cellAutoButton)
        addSubview(cellSettingLabel)
        addSubview(cellTutorialButton)
        
        cellAutoButton.addTarget(self, action: #selector(PrivacyCell.cellButtonAction(_:)), for: .touchUpInside)
        
        cellTutorialButton.addTarget(self, action: #selector(PrivacyCell.cellButtonAction(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            cellTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            cellTitleLabel.widthAnchor.constraint(lessThanOrEqualTo: cellTitleLabel.widthAnchor),
            
            cellICharLabel.leadingAnchor.constraint(lessThanOrEqualTo: cellTitleLabel.trailingAnchor),
            cellICharLabel.heightAnchor.constraint(equalToConstant: 12.0),
            cellICharLabel.widthAnchor.constraint(equalToConstant: 12.0),
            cellICharLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -4.0),
            
            cellAutoButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellAutoButton.heightAnchor.constraint(equalToConstant: buttonWidth),
            cellAutoButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            cellAutoButton.trailingAnchor.constraint(equalTo: cellSettingLabel.leadingAnchor),
            
            cellSettingLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellSettingLabel.widthAnchor.constraint(equalToConstant: buttonWidth),
            cellSettingLabel.trailingAnchor.constraint(equalTo: cellTutorialButton.leadingAnchor),
            
            cellTutorialButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellTutorialButton.heightAnchor.constraint(equalToConstant: buttonWidth),
            cellTutorialButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            cellTutorialButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.0)
        ])
    }
    
    @objc func cellButtonAction(_ sender: Any) {
        cellDelegate?.privacyCell(cell: self, didTappped: sender as! UIButton)
    }
    
    func setupButtonsParameters() {
        if ScreenSize.largeScreen {
            buttonWidth = 40
        } else if ScreenSize.middleScreen {
            buttonWidth = 40
        } else if ScreenSize.smallScreen {
            buttonWidth = 30
        }
    }
    
    func updateCellWith(settingName: String, settingIsOn: Bool, settingLabelTag: Int, settingButtonTag: Int, settingAutoButtonTag: Int, settingLabelColor: UIColor, settingIsAuto: Bool, settingHasInfo: Bool) {
        cellTitleLabel.text = settingName
        cellICharLabel.isHidden = !settingHasInfo
        cellAutoButton.isHidden = !settingIsAuto
        cellAutoButton.tag = settingAutoButtonTag
        cellSettingLabel.setupParameters(labelIsOn: settingIsOn, labelTextColor: settingLabelColor, labelTag: settingLabelTag)
        cellTutorialButton.tag = settingButtonTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
