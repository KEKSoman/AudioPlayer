//
//  PlaylistCell.swift
//  AudioPlayer
//
//  Created by Евгений колесников on 01.09.2022.
//

import UIKit

class PlaylistCell: UITableViewCell {

    @IBOutlet weak var songImage: UIImageView?
    @IBOutlet weak var songTitle: UILabel?
    @IBOutlet weak var separateView: UIView?
    @IBOutlet weak var playIcon: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        songTitle?.textColor = .white
        separateView?.backgroundColor = hexStringToUIColor(hex: "a2d7de").withAlphaComponent(0.4)
        playIcon?.isHidden = true
    }

    
}
