//
//  GameOverScene.swift
//  GG1L9UbeyPidara
//
//  Created by Ivan Vasilevich on 5/26/17.
//  Copyright © 2017 Smoosh Labs. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameOverScene: SKScene {

    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.white
        
        // 2
        let message = "You Lose :["
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 4
        run(SKAction.sequence([SKAction.run() {
                // 5
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                self.view?.presentScene(scene)
            }
//                let reveal = SKTransition.flipHorizontal(withDuration: 0.2)
//                let scene = GameScene(size: self.size)
//                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
