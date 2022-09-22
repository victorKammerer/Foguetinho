//
//  ViewController.swift
//  FlappyBirdUIKit
//
//  Created by vko on 05/09/22.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        let scene = GameScene(size: skView.frame.size)
        
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}
