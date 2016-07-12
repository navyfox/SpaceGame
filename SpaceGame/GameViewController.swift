//
//  GameViewController.swift
//  SpaceGame
//
//  Created by p1us on 26.08.15.
//  Copyright (c) 2015 Ivan Akulov. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var gameScene: GameScene!

    @IBAction func pauseButtonPressed(sender: AnyObject) {
        gameScene.pauseButtonPressed(sender)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true

            gameScene = scene

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill

            scene.size = UIScreen.mainScreen().bounds.size
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
