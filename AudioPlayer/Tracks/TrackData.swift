//
//  TrackData.swift
//  AudioPlayer
//
//  Created by Евгений колесников on 01.09.2022.
//

import Foundation
import UIKit
import MediaPlayer
import AVFoundation

struct TrackData {
    
    let id: Int
    let title: String?
    let artist: String?
    let cover: UIImage?
    let fullTitle: String
}

class TrackList {
    
    var id: Int = 0
    var title: String?
    var artist: String?
    var cover: UIImage?
    var fullTitle: String?
    
    var tracks: [TrackData] = []
    static let shared = TrackList()
    let trackList = [
        "И дельфины - любовь реальна",
        "И дельфины - хладнокровие теплокровных",
        "City of the Lost - G2V ",
        "Cky - 96 Quite Bitter Beings",
        "Fools Garden-Lemon Tree",
        "Ghost Dance - Last Train",
        "Ghost Dance - The Grip Of Love",
        "Placebo - Pure Morning",
        "Silverchair - Pure Massacre ",
        "Travis - Side"
    ]
    
    func getTrackList() -> [TrackData] {
        
        for i in trackList {
            id += 1
            guard let audioPath = Bundle.main.url(forResource: i, withExtension: ".mp3") else {
                print("url nof found")
                continue
            }
            
            let playerItem = AVPlayerItem(url: audioPath)
            let metadataList = playerItem.asset.metadata
            
            for item in metadataList {
                if let stringValue = item.value {
                    
                    if item.commonKey?.rawValue == "artist" {
                        self.artist = stringValue as? String
                    }
                    if item.commonKey?.rawValue == "title" {
                        self.title = stringValue as? String
                    }
                    if item.commonKey?.rawValue == "artwork" {
                        
                        guard let imageData = item.dataValue else {
                            continue
                        }
                        
                        self.cover = UIImage(data: imageData)
                    } else {
                        self.cover = UIImage(named: "default.song")
                    }
                }
            }
            let trackMetadata = TrackData(id: id,
                                          title: title,
                                          artist: artist,
                                          cover: cover,
                                          fullTitle: i)
            guard !tracks.contains(where: { trackData in
                trackData.fullTitle == trackMetadata.fullTitle
            }) else {
                continue
            }
            tracks.append(trackMetadata)
        }
        return tracks
    }
}
