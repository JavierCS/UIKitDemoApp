//
//  TestViewController.swift
//  UIKitDemoApp
//
//  Created by Javier Cruz Santiago on 14/10/24.
//

import UIKit

enum ViewVisivility {
    case full
    case intermediate
    case hideen
}

class TestViewController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var someContentView: UIView!
    @IBOutlet weak var topTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Logic Vars
    var viewVisivility: ViewVisivility = .full
    var sizeToGrow: CGFloat = 150
    var topTableConstraintConstant: CGFloat = 0
    
    // MARK: - Life Cycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        title = "Test Controller"
        configureTable()
    }
    
    private func configureTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension TestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "Celda \(indexPath.row)"
        cell.contentConfiguration = content
        return cell
    }
}

extension TestViewController: UITableViewDelegate {
    
}

extension TestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        if offset >= 0 && topTableConstraintConstant == -sizeToGrow {
            return
        }
        
        topTableConstraintConstant += -offset
        if abs(topTableConstraintConstant) >= sizeToGrow {
            topTableConstraintConstant = -sizeToGrow
        } else if topTableConstraintConstant >= 0 {
            topTableConstraintConstant = 0
        }
        
        topTableViewConstraint.constant = topTableConstraintConstant
        scrollView.contentOffset = .zero
    }
}
