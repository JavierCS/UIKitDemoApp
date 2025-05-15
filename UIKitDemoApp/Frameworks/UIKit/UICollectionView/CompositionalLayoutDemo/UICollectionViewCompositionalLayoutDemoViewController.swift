//
//  UICollectionViewCompositionalLayoutDemoViewController.swift
//  UIKitDemoApp
//
//  Created by Javier Cruz Santiago on 08/10/24.
//

import UIKit

class UICollectionViewCompositionalLayoutDemoViewController: UIViewController {
    // MARK: - UIElements
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfiguration()
    }
    
    // MARK: - Initial Configuration Management
    private func initialConfiguration() {
        title = "Compositional Layout"
    }
}
