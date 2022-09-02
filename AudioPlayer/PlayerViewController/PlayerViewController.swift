//
//  ViewController.swift
//  AudioPlayer
//
//  Created by Евгений колесников on 01.09.2022.
//

import UIKit
import MediaPlayer
import AVFoundation
import MobileCoreServices

//MARK: - TODO
// download tracks from files (h)

final class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playlist: PlayerView?
    @IBOutlet weak var coverImage: UIImageView?
    @IBOutlet weak var songLabel: UILabel?
    @IBOutlet weak var artistLabel: UILabel?
    @IBOutlet weak var currentTime: UILabel?
    @IBOutlet weak var fullTime: UILabel?
    @IBOutlet weak var bottomView: UIView?
    @IBOutlet weak var loopButton: PlayerView?
    @IBOutlet weak var songProgress: UISlider?
    @IBOutlet weak var randomButton: PlayerView?
    @IBOutlet weak var prevTrack: PlayerView?
    @IBOutlet weak var playPause: PlayerView?
    @IBOutlet weak var nextTrack: PlayerView?
    @IBOutlet weak var filesButton: PlayerView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var shareButton: PlayerView?
    
    private var player: AVAudioPlayer?
    private var selectedTrack: TrackData?
    
    private let tracks = TrackList.shared.getTrackList()
    private var isMusicPlayed: Bool = false {
        didSet {
            if isMusicPlayed {
                playPause?.image = UIImage(named: "pause")!
            } else {
                playPause?.image = UIImage(named: "play")!
            }
        }
    }
    
    private var isLoopEnabled: Bool = false {
        didSet {
            if isLoopEnabled {
                animateOff(view: loopButton)
                animateOff(view: randomButton)
                randomButton?.isEnabled = false
                isRandomEnabled = false
                
            } else {
                animateOn(view: loopButton)
                randomButton?.isEnabled = true
            }
        }
    }
    
    private var isRandomEnabled: Bool = false {
        didSet {
            if isRandomEnabled {
                animateOff(view: randomButton)
            } else {
                animateOn(view: randomButton)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupProgressTimer()
        setupSlider()
    }
    
    override func viewWillLayoutSubviews() {
        view.backgroundGradient()
    }
    
    // MARK: - UI Setting
    private func setUI() {
        
        // UI
        [artistLabel, songLabel].forEach { item in
            item?.textColor = .white
            item?.text = ""
        }
        songLabel?.font = customFont(type: .Bold, size: 24)
        artistLabel?.font = customFont(type: .Regular, size: 18)
        
        [currentTime, fullTime].forEach { item in
            item?.text = "00 : 00 : 00 : 00"
            item?.textColor = .white
            item?.font = customFont(type: .Medium, size: 14)
        }
        titleLabel?.text = "Audio Player"
        titleLabel?.font = customFont(type: .Bold, size: 18)
        
        filesButton?.text = "Files"
        playlist?.text = "Local"
        [filesButton, playlist].forEach { item in
            item?.textColor = .white
            item?.font = customFont(type: .Medium, size: 14)
        }
        
        bottomView?.backgroundColor = .black.withAlphaComponent(0.5)
        isLoopEnabled = false
        isRandomEnabled = false
        coverImage?.contentMode = .scaleAspectFit
        
        // Images
        prevTrack?.image = UIImage(named: "prev")!
        playPause?.image = UIImage(named: "play")!
        nextTrack?.image = UIImage(named: "next")!
        loopButton?.image = UIImage(named: "loop")!
        randomButton?.image = UIImage(named: "random")!
        shareButton?.image = UIImage(named: "share")!
        
        // buttons target
        playlist?.button.addTarget(self, action: #selector(showPlaylist), for: .touchUpInside)
        songProgress?.addTarget(self, action: #selector(songRewind), for: .valueChanged)
        playPause?.button.addTarget(self, action: #selector(playPauseMusic), for: .touchUpInside)
        loopButton?.button.addTarget(self, action: #selector(loopMusicAction), for: .touchUpInside)
        nextTrack?.button.addTarget(self, action: #selector(nextTrackAction), for: .touchUpInside)
        prevTrack?.button.addTarget(self, action: #selector(prevTrackAction), for: .touchUpInside)
        filesButton?.button.addTarget(self, action: #selector(getAudioFromFiles), for: .touchUpInside)
        randomButton?.button.addTarget(self, action: #selector(randomTrackAction), for: .touchUpInside)
        shareButton?.button.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
    }
    
    private func updateUI(trackData: TrackData) {
        self.artistLabel?.text = trackData.artist
        self.songLabel?.text = trackData.title
        self.coverImage?.image = trackData.cover
        
        
        let floatDuration = getAudioDuration()
        let dounbleDuration = Double(floatDuration)
        let ms = Int((dounbleDuration*1000).truncatingRemainder(dividingBy: 100))
        let seconds = Int(dounbleDuration) % 60
        let min = Int(dounbleDuration) / 60
        let hours = Int(dounbleDuration) / 3600
        
        self.fullTime?.text = String(format: "%.2i : %.2i : %.2i : %.2i", hours, min, seconds, ms)
        setupSlider()
        playMusic(name: trackData.fullTitle)
    }
    
    private func animateOn(view: PlayerView?) {
        UIView.animate(withDuration: 0.6) {
            view?.bgColor = hexStringToUIColor(hex: "7066CC")
        }
    }
    
    private func animateOff(view: PlayerView?) {
        UIView.animate(withDuration: 0.6) {
            view?.bgColor = hexStringToUIColor(hex: "bf6ddb")
        }
    }
    
    //MARK: - Button methods
    
    @objc private func playPauseMusic() {
        
        if self.selectedTrack == nil {
            selectedTrack = tracks.randomElement()
            updateUI(trackData: selectedTrack!)
            playMusic(name: selectedTrack?.fullTitle)
            return
        }
        
        isMusicPlayed ? pauseMusic() : resumeMusic()
    }
    
    @objc private func loopMusicAction() {
        if isLoopEnabled {
            player?.numberOfLoops = -1
            isLoopEnabled = false
        } else {
            player?.numberOfLoops = 0
            isLoopEnabled = true
        }
    }
    
    @objc private func nextTrackAction() {
        guard var selectedTrack = selectedTrack else { return }
        var currentId = selectedTrack.id
        player?.stop()
        guard !isLoopEnabled else {
            playMusic(name: selectedTrack.fullTitle)
            updateUI(trackData: selectedTrack)
            return
        }
        
        guard !isRandomEnabled else {
            selectedTrack = tracks.randomElement()!
            self.selectedTrack = selectedTrack
            updateUI(trackData: selectedTrack)
            playMusic(name: selectedTrack.fullTitle)
            return
        }
        
        if currentId == 10 {
            currentId = 1
        }
        let nextSong = tracks.first { trackData in
            trackData.id == currentId + 1
        }
        self.selectedTrack = nextSong
        updateUI(trackData: nextSong!)
        
    }
    
    @objc private func prevTrackAction() {
        guard var selectedTrack = selectedTrack else {
            return
        }
        var currentId = selectedTrack.id
        
        guard !isLoopEnabled else {
            playMusic(name: selectedTrack.fullTitle)
            updateUI(trackData: selectedTrack)
            return
        }
        
        guard !isRandomEnabled else {
            selectedTrack = tracks.randomElement()!
            self.selectedTrack = selectedTrack
            updateUI(trackData: selectedTrack)
            playMusic(name: selectedTrack.fullTitle)
            return
        }
        
        if currentId == 1 {
            currentId = 11
        }
        
        let prevSong = tracks.first { trackData in
            trackData.id == currentId - 1
        }
        self.selectedTrack = prevSong
        updateUI(trackData: prevSong!)
    }
    
    @objc private func randomTrackAction() {
        if isRandomEnabled {
            
            isRandomEnabled = false
        } else {
            
            isRandomEnabled = true
        }
    }
    
    @objc private func shareAction() {
        
        let first = "Just listen it!"
        let second = selectedTrack?.fullTitle ?? "Unknown"
        let image = selectedTrack?.cover ?? UIImage(named: "default.song")!
        
        let activityIndicator = UIActivityViewController(activityItems: [first, second, image], applicationActivities: nil)
        activityIndicator.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToTwitter
        ]
        activityIndicator.isModalInPresentation = true
        self.present(activityIndicator, animated: true)
    }
    
    @objc private func showPlaylist() {
        let playListVC = PlaylistViewController(trackData: selectedTrack)
        playListVC.delegate = self
        self.present(playListVC, animated: true)
    }
    
    @objc private func songRewind() {
        guard let songProgress = songProgress else {
            return
        }
        player?.currentTime = Double(songProgress.value)
        updateProgress()
    }
    
    //MARK: - Music methods
    
    private func playMusic(name: String?) {
        guard let name = name, !name.isEmpty else { return }
        
        let pathToSound = Bundle.main.path(forResource: name, ofType: "mp3")!
        let url = URL(fileURLWithPath: pathToSound)
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playback)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
        isMusicPlayed = true
    }
    
    private func resumeMusic() {
        player?.play()
        isMusicPlayed = true
    }
    
    private func pauseMusic() {
        player?.pause()
        isMusicPlayed = false
    }
    
    private func loopMusic() {
        player?.numberOfLoops = -1
    }
    
    // MARK: - Support
    
    private func setupProgressTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { [weak self] (completion) in
            guard let self = self else { return }
            self.updateProgress()
        })
    }
    
    private func updateProgress() {
        guard let duration = player?.currentTime else { return }
        let ms = Int((duration*1000).truncatingRemainder(dividingBy: 100))
        let seconds = Int(duration) % 60
        let min = Int(duration) / 60
        let hours = Int(duration) / 3600
        
        self.currentTime?.text = String(format: "%.2i : %.2i : %.2i : %.2i", hours, min, seconds, ms)
        
        self.songProgress?.value = Float(duration)
    }
    private func setupSlider() {
        songProgress?.minimumValue = 0
        songProgress?.maximumValue = Float(getAudioDuration())
    }
    
    private func getAudioDuration() -> Float64 {
        let fullName = selectedTrack?.fullTitle
        let pathToSound = Bundle.main.path(forResource: fullName, ofType: "mp3")!
        let audioFileURL = URL(fileURLWithPath: pathToSound)
        let audioAsset = AVURLAsset.init(url: audioFileURL, options: nil)
        let duration = audioAsset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        return durationInSeconds
    }
    
    @objc private func getAudioFromFiles() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.mp3"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true)
    }
}
//MARK: - Playlist Protocol

extension PlayerViewController: SongDataDelegate {
    func showSongData(trackData: TrackData) {
        self.selectedTrack = trackData
        self.updateUI(trackData: trackData)
    }
}

//MARK: - UIDocumentPickerDelegate

extension PlayerViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        addAudio(audioUrl: selectedFileURL)
    }
    
    func addAudio(audioUrl: URL) {
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            self.playMusic(url: destinationUrl)
        } else {
            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    
                    self.playMusic(url: destinationUrl)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
        }
    }
    
    func playMusic(url: URL) {
        do {
            getMetadata(url: url)
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSession.Category.playback)
            self.player?.play()
            self.isMusicPlayed = true
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getMetadata(url: URL) {
        var title: String?
        var artist: String?
        var cover: UIImage?
        var fullTitle: String
        
        let asset = AVAsset(url: url)
        print(asset.metadata)
        asset.metadata.compactMap { item in
            if let stringValue = item.value {
                if item.commonKey?.rawValue == "artist" {
                    artist = stringValue as? String
                    artistLabel?.text = artist
                }
                
                if item.commonKey?.rawValue == "title" {
                    title = stringValue as? String
                    songLabel?.text = title
                }
                
                if item.commonKey?.rawValue == "artwork" {
                    
                    guard let imageData = item.dataValue else {
                        cover = UIImage(named: "default.song")
                        self.coverImage?.image = cover
                        return
                    }
                    cover = UIImage(data: imageData)
                    self.coverImage?.image = cover
                } else {
                    cover = UIImage(named: "default.song")
                    self.coverImage?.image = cover
                }
            }
        }
        selectedTrack = TrackData(id: -1,
                                  title: title,
                                  artist: artist,
                                  cover: cover,
                                  fullTitle: "\(artist ?? "Unknown artist") - \(title ?? "Unknown title")")
    }
}
