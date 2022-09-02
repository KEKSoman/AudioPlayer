//
//  PlayerView.swift
//  AudioPlayer
//
//  Created by Евгений колесников on 02.09.2022.
//

import Foundation
import UIKit
import SnapKit

class PlayerView: UIView {
    
    let button = UIButton()
    let imageView = UIImageView()
    let label = UILabel()
    
    var text: String = "" {
        didSet {
            self.label.text = text
        }
    }
    
    var image = UIImage() {
        didSet {
            DispatchQueue.main.async {
                self.imageView.image = self.image
            }
            
        }
    }
    
    var font = UIFont() {
        didSet {
            self.label.font = font
        }
    }
    
    var textColor: UIColor = .white {
        didSet {
            self.label.textColor = textColor
        }
    }
    
    var textAligment: NSTextAlignment = .center {
        didSet {
            self.label.textAlignment = textAligment
        }
    }
    
    var bgColor: UIColor = hexStringToUIColor(hex: "7066CC") {
        didSet {
            self.backgroundColor = bgColor
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            self.button.isEnabled = isEnabled
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(label)
        self.addSubview(imageView)
        self.addSubview(button)
        
        setConstrants()
        setUI()
    }
    
    override func layoutSubviews() {
        self.buttonShadow()
    }
    
    private func setConstrants() {
        button.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        label.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self).inset(5)
            make.right.equalTo(self).inset(5)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerY.equalTo(self)
            make.centerX.equalTo(self)
        }
    }
    
    private func setUI() {
        self.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(vibro), for: .touchUpInside)
        self.bgColor = hexStringToUIColor(hex: "7066CC")
        self.label.textAlignment = .center
    }
    @objc private func vibro() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
           generator.impactOccurred()
    }
}
