//
//  ViewControllerExt.swift
//  AudioPlayer
//
//  Created by Евгений колесников on 02.09.2022.
//

import Foundation
import UIKit

extension UIView {
    func backgroundGradient() {
        let gradient = CAGradientLayer()
        let firstColor = hexStringToUIColor(hex: "#bf6ddb").cgColor
        let secondColor = hexStringToUIColor(hex: "#182172").cgColor
        gradient.colors = [firstColor, secondColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func buttonShadow() {
        self.layer.shadowColor = hexStringToUIColor(hex: "bf6ddb").cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
    }
}
