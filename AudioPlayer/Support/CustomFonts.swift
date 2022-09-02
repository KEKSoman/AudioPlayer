//
//  CustomFonts.swift
//  AudioPlayer
//
//  Created by Евгений колесников on 02.09.2022.
//

import Foundation
import UIKit

enum Fonts: String {
    case Bold
    case Medium
    case Regular
}
    func customFont(type: Fonts, size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-"+type.rawValue, size: size) ?? UIFont.systemFont(ofSize: 14)
    }

