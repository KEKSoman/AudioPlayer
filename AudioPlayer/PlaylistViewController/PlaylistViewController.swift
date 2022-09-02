//
//  PlaylistViewController.swift
//  AudioPlayer
//
//  Created by Евгений колесников on 01.09.2022.
//

import UIKit

protocol SongDataDelegate {
    func showSongData(trackData: TrackData)
}


final class PlaylistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var titleLabel: UILabel?
    
   private let cell = "PlaylistCell"
   private var currentTrack: TrackData?
    var delegate: SongDataDelegate?
   private var tracks = TrackList.shared.getTrackList()
    
    init(trackData: TrackData?) {
        self.currentTrack = trackData
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = "Local Playlist"
        titleLabel?.textColor = .white
        
        tableView?.register(UINib(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = .clear
        tableView?.separatorColor = .clear
    }
    
    override func viewWillLayoutSubviews() {
        view.backgroundGradient()
    }
    
    @objc private func changeTrack() {
        print("Track changed")
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension PlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PlaylistCell else { return }
        let track = tracks[indexPath.row]
        cell.songImage?.image = track.cover
        cell.songTitle?.text = "\(track.artist ?? "Unknown artist") - \(track.title ?? "Unknown song")"
        cell.playIcon?.isHidden = currentTrack?.fullTitle == track.fullTitle ? false : true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.showSongData(trackData: tracks[indexPath.row])
        self.dismiss(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
