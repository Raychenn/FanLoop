//
//  ViewController.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/10.
//

import UIKit

class ShortsVideoController: UIViewController {
    
    private let viewModel: VideoListViewModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(VideoCell.self, forCellReuseIdentifier: String(describing: VideoCell.self))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
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
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupBindings() {
        viewModel.videosUpdateHandler = { [weak self] videos in
            Task.detached { @MainActor in
                self?.tableView.reloadData()
            }
        }
        
        viewModel.errorUpdateHandler = { [weak self] error in
            Task.detached { @MainActor in
                if let error = error {
                    print("handle error: \(error)")
                }
            }
        }
        
        viewModel.loadingUpdateHandler = { [weak self] isLoading in
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
        // Get visible cells
        guard let visibleCells = tableView.visibleCells as? [VideoCell] else { return }
        
        for cell in visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else { continue }
            
            // Calculate how much of the cell is visible
            let cellFrame = tableView.convert(cell.frame, to: tableView.superview)
            let cellVisibleHeight = cellFrame.intersection(tableView.frame).height
            let cellTotalHeight = cell.frame.height
            let visibilityPercentage = cellVisibleHeight / cellTotalHeight
            
            // If cell is more than 50% visible, play it and pause others
            if visibilityPercentage > 0.5 {
                cell.play()
                
                // Pause all other visible cells
                visibleCells.forEach { otherCell in
                    if otherCell != cell {
                        otherCell.pause()
                    }
                }
                break // Only play one video at a time
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Snap to the nearest cell when scrolling ends
        let page = Int(scrollView.contentOffset.y / scrollView.bounds.height)
        let yOffset = CGFloat(page) * scrollView.bounds.height
        scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
    }
}
