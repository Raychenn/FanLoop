//
//  ViewController.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/10.
//

import UIKit

class ShortsVideoController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "FanLoop"
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
