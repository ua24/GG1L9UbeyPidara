//
//  GameScene.swift
//  GG1L9UbeyPidara
//
//  Created by Ivan Vasilevich on 5/24/17.
//  Copyright © 2017 Smoosh Labs. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let hunter = SKSpriteNode(imageNamed: "picHunter")
    var shootingTimer: Timer?
    
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
            label.text = "Ubey Pidara"
        }
        
        addChild(hunter)
        hunter.setScale(0.3)
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(spawnEnemy), userInfo: nil, repeats: true)
        
        
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    func spawnEnemy() {
        let bearNode = SKSpriteNode(imageNamed: "bear")
        addChild(bearNode)
        bearNode.size = hunter.size
        let a = arc4random()%UInt32(size.width)
        let b = UInt32(size.width)/2
        
        let xPos = Int(Double(a) - Double(b))
        let yPos = Int(Double(arc4random()%UInt32(size.height)) - Double(UInt32(size.height)/2))
        bearNode.position = CGPoint(x: xPos, y: yPos)
        bearNode.run(SKAction.sequence([SKAction.move(to: hunter.position, duration: 1), SKAction.removeFromParent()]))
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        startShootingTimer()
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
    }
    
    func startShootingTimer() {
        shootingTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(shoot), userInfo: nil, repeats: true)
    }
    
    func shoot() {
        let granadeNode = SKSpriteNode(imageNamed: "bee")
        addChild(granadeNode)
        granadeNode.size = hunter.size
        granadeNode.setScale(0.4)
        granadeNode.position = hunter.position
        let blowUp = SKAction.customAction(withDuration: 0.05) { (node, dura) in
            let meatNode = SKSpriteNode(imageNamed: "explosion")
            meatNode.position = node.position
            self.addChild(meatNode)
            meatNode.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeOut(withDuration: 1) , SKAction.removeFromParent()]))
        }
        granadeNode.run(SKAction.sequence([SKAction.move(to: shottingPoint, duration: 0.1), blowUp, SKAction.removeFromParent()]))
//        shottingPoint
    }
    
    func stopShootingTimer() {
        shootingTimer?.invalidate()
    }
    var shottingPoint = CGPoint.zero
    func touchMoved(toPoint pos : CGPoint) {
        shottingPoint = pos
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        stopShootingTimer()
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
