//
//  GameViewController.swift
//  SpaceSurvival iOS
//
//  Created by Aluno Tmp on 04/06/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1) Recupere o SKView
        let skView = self.view as! SKView
        
        // 2) Crie a cena com o tamanho exato da view
        let scene = GameScene(size: skView.bounds.size)
        
        // 3) Faça a cena preencher exatamente a view
        scene.scaleMode = .resizeFill
        
        // 4) Apresente a cena
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
