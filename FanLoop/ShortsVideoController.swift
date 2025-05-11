//
//  ViewController.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/10.
//

import UIKit

class ShortsVideoController: UIViewController {
    
    private let viewModel: VideoListViewModel
    
    private var currentlyPlayingCell: VideoCell?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(VideoCell.self, forCellReuseIdentifier: String(describing: VideoCell.self))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(viewModel: VideoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        viewModel.fetchVideos()
    }

    private func setupUI() {
        title = "FanLoop"
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.videosUpdateHandler = { [weak self] videos in
            Task.detached { @MainActor in
                self?.tableView.reloadData()
                self?.updatePlaybackForMostVisibleCell()
            }
        }
        
        viewModel.errorUpdateHandler = { _ in
            Task.detached { @MainActor in
                print("handle error here")
            }
        }
        
        viewModel.loadingUpdateHandler = { [weak self] isLoading in
            isLoading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
        }
    }
    
    private func updatePlaybackForMostVisibleCell() {
        guard let visibleCells = tableView.visibleCells as? [VideoCell] else { return }

        var bestCandidate: VideoCell?
        var maxVisibleHeight: CGFloat = 0

        for cell in visibleCells {
            let cellFrame = tableView.convert(cell.frame, to: tableView.superview)
            let visibleHeight = cellFrame.intersection(tableView.frame).height
            let visibilityRatio = visibleHeight / cell.frame.height

            if visibilityRatio > 0.5 && visibleHeight > maxVisibleHeight {
                bestCandidate = cell
                maxVisibleHeight = visibleHeight
            }
        }

        if let candidate = bestCandidate, candidate != currentlyPlayingCell {
            currentlyPlayingCell?.pause()
            candidate.play()
            currentlyPlayingCell = candidate
        }
    }
}

 // MARK: UITableViewDataSource

extension ShortsVideoController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.identifier, for: indexPath) as? VideoCell else {
            return UITableViewCell()
        }
        
        let video = viewModel.videos[indexPath.row]
        cell.configure(with: video)
        
        return cell
    }
    
}

// MARK: UITableViewDelegate
extension ShortsVideoController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePlaybackForMostVisibleCell()
    }
}
