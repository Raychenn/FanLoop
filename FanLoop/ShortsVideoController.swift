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
        viewModel.fetchVideos()

    }

    private func setupUI() {
        title = "FanLoop"
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
        20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
}

// MARK: UITableViewDelegate
extension ShortsVideoController: UITableViewDelegate {
    
}
