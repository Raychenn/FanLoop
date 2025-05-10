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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = contentView.bounds
            playerLayer?.videoGravity = .resizeAspectFill

            if let layer = playerLayer {
                videoContainerView.layer.addSublayer(layer)
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

    // MARK: - Layout

    private func setupViews() {
        contentView.addSubview(videoContainerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            videoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            videoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            videoContainerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * videoHeightRatio),
            
            titleLabel.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }
}
