//
//  VideoCell.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/10.
//

import UIKit
import AVFoundation

class VideoCell: UITableViewCell {
    
    static let identifier = "VideoCell"
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let videoHeightRatio: CGFloat = 0.75
    private var isMuted: Bool = false {
        didSet {
            let image = isMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.fill")
            muteButton.setImage(image, for: .normal)
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var muteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "speaker.fill")?.withTintColor(.black), for: .normal)
        button.addTarget(self, action: #selector(didTapMuteButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with video: Video) {
        if let path = Bundle.main.url(forResource: video.url, withExtension: "mp4") {
            titleLabel.text = video.title
            subtitleLabel.text = video.subTitle
            
            player = AVPlayer(url: path)
            player?.isMuted = self.isMuted
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = contentView.bounds
            playerLayer?.videoGravity = .resizeAspectFill

            if let layer = playerLayer {
                videoContainerView.layer.insertSublayer(layer, at: 0)
            }
        } else {
            print("⚠️ Video not found: \(video.url).mp4")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }
    
    @objc func didTapMuteButton() {
        isMuted.toggle()
    }

    // MARK: - Layout

    private func setupViews() {
        contentView.addSubview(videoContainerView)
        videoContainerView.addSubview(muteButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            videoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            videoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            videoContainerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * videoHeightRatio),
            
            muteButton.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor, constant: -8),
            muteButton.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: -8),
            muteButton.widthAnchor.constraint(equalToConstant: 20),
            muteButton.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor, constant: -8),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }
}
