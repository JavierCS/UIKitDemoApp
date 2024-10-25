//
//  TestViewController.swift
//  UIKitDemoApp
//
//  Created by Javier Cruz Santiago on 14/10/24.
//

import UIKit

enum ViewVisivility {
    case full
    case intermediate(CGFloat)
    case hidden
}

enum HideableScrollDirection {
    case up
    case down
}

class HideableMenuHeaderManager: NSObject {
    private var topMenuConstraint: NSLayoutConstraint?
    
    private var viewVisivility: ViewVisivility = .full
    private var maxVisibleSize: CGFloat
    private var topMenuConstraintConstant: CGFloat = 0
    
    private var originalTableDelegate: UITableViewDelegate?
    
    init(maxVisibleSize: CGFloat) {
        self.maxVisibleSize = maxVisibleSize
    }
    
    func configure(topConstraint constraint: NSLayoutConstraint, tableViewDelegate delegate: UITableViewDelegate?) {
        topMenuConstraint = constraint
        originalTableDelegate = delegate
    }
    
    func setTopConstraint(_ constraint: NSLayoutConstraint) {
        topMenuConstraint = constraint
    }
    
    func setTableDelegate(_ delegate: UITableViewDelegate) {
        originalTableDelegate = delegate
    }
}

extension HideableMenuHeaderManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        originalTableDelegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}

extension HideableMenuHeaderManager: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        defer {
            originalTableDelegate?.scrollViewDidScroll?(scrollView)
        }
        let offset = scrollView.contentOffset.y
        
        if offset >= 0 && topMenuConstraintConstant == -maxVisibleSize {
            viewVisivility = .hidden
            return
        }
        
        if offset < 0 && topMenuConstraintConstant == 0 {
            viewVisivility = .full
            return
        }
        
        topMenuConstraintConstant += -offset
        if abs(topMenuConstraintConstant) >= maxVisibleSize {
            topMenuConstraintConstant = -maxVisibleSize
        } else if topMenuConstraintConstant >= 0 {
            topMenuConstraintConstant = 0
        }
        
        topMenuConstraint?.constant = topMenuConstraintConstant
        viewVisivility = .intermediate(topMenuConstraintConstant)
        scrollView.contentOffset = .zero
    }
}

class TestViewController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var someContentView: UIView!
    @IBOutlet weak var topTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    lazy var refreshControl = UIRefreshControl()
    
    let menuHeaderManager = HideableMenuHeaderManager(maxVisibleSize: 150)
    
    // MARK: - Logic Vars
    
    
    // MARK: - Life Cycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Device.shared.unlockScreenShot()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Device.shared.lockScreenShot()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        title = "Test Controller"
        configureTable()
    }
    
    private func configureTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = menuHeaderManager
        tableView.refreshControl = refreshControl
        menuHeaderManager.configure(topConstraint: topTableViewConstraint, tableViewDelegate: self)
    }
}

extension TestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected Row")
    }
}

extension TestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
    }
}
