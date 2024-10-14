//
//  TestViewController.swift
//  UIKitDemoApp
//
//  Created by Javier Cruz Santiago on 14/10/24.
//

import UIKit

class TestViewController: UIViewController {
    // MARK: - UIElements
    
    // MARK: - Life Cycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Configuration Management
    private func initialConfiguration() {
        title = "Test Controller"
    }
}
