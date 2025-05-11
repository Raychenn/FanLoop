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
    private var playerItemEndObserver: NSObjectProtocol?
    private let videoHeightRatio: CGFloat = 0.75
    private var isTitleExpanded = false
    private var isSubtitleExpanded = false
    private var isMuted: Bool = false {
        didSet {
            let image = isMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.fill")
            muteButton.setImage(image, for: .normal)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    private lazy var  subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(subtitleLabelTapped))
        label.addGestureRecognizer(tapGesture)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
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
            setupPlayerLooping()
        } else {
            print("⚠️ Video not found: \(video.url).mp4")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Remove the observer when the cell is reused
        if let observer = playerItemEndObserver {
            NotificationCenter.default.removeObserver(observer)
            playerItemEndObserver = nil
        }
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    deinit {
        // Clean up observer when cell is deallocated
        if let observer = playerItemEndObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Helpers
    
    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }
    
    @objc func didTapMuteButton() {
        isMuted.toggle()
    }
    
    @objc private func titleLabelTapped() {
        toggleLabelExpansion(for: titleLabel, isExpanded: &isTitleExpanded)
    }
    
    @objc private func subtitleLabelTapped() {
        toggleLabelExpansion(for: subtitleLabel, isExpanded: &isSubtitleExpanded)
    }
    
    private func toggleLabelExpansion(for label: UILabel, isExpanded: inout Bool) {
        isExpanded.toggle()
        let expanded = isExpanded
        
        UIView.animate(withDuration: 0.3) {
            label.numberOfLines = expanded ? 0 : 1
            self.layoutIfNeeded()
            
            if let tableView = self.superview as? UITableView {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }

    // MARK: - Layout

    private func setupViews() {
        contentView.addSubview(videoContainerView)
        videoContainerView.addSubview(muteButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        let labelsStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 8
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelsStackView)

        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            videoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            videoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            videoContainerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * videoHeightRatio),
            
            muteButton.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor, constant: -8),
            muteButton.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: -8),
            muteButton.widthAnchor.constraint(equalToConstant: 20),
            muteButton.heightAnchor.constraint(equalToConstant: 20),
            
            labelsStackView.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: 8),
            labelsStackView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor, constant: 8),
            labelsStackView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor, constant: -16),
            labelsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupPlayerLooping() {
        // Remove existing observer if any
        if let observer = playerItemEndObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // Add new observer
        playerItemEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main) { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
        }
    }
}
