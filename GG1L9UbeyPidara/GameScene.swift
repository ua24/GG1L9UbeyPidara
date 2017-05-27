//
//  GameScene.swift
//  GG1L9UbeyPidara
//
//  Created by Ivan Vasilevich on 5/24/17.
//  Copyright © 2017 Smoosh Labs. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Monster   : UInt32 = 0b1       // 1
        static let Projectile: UInt32 = 0b10      // 2
    }
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let hunter = SKSpriteNode(imageNamed: "picHunter")
    let leftJoystick = AnalogJoystick.init(diameters: (substrate: 100, stick: 50))
    let rightJoystick = AnalogJoystick(diameter: 100)
    var gameOverFlag = false
    
    var shootingTimer: Timer?
    var medvedTimer: Timer?
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
            label.text = "Ubey Pidara"
        }
        
        addChild(hunter)
        hunter.position = .zero
        hunter.setScale(0.3)
        hunter.physicsBody = SKPhysicsBody(circleOfRadius: hunter.size.width/2)
        hunter.physicsBody?.collisionBitMask = PhysicsCategory.All
        hunter.physicsBody?.contactTestBitMask = PhysicsCategory.All
        hunter.physicsBody?.isDynamic = true
        hunter.name = "hunter"
        
        medvedTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(spawnEnemy), userInfo: nil, repeats: true)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector.zero
        
        
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
        
        //ADD Joysticks
        
        addChild(leftJoystick)
        let a: CGFloat = 100
        leftJoystick.position = CGPoint(x: -size.width/2 + a, y: -a)
        leftJoystick.substrate.color = .red
//        leftJoystick.stick
        addChild(rightJoystick)
        rightJoystick.position = CGPoint(x: size.width/2 - a, y: -size.height/2 + a)
        rightJoystick.substrate.color = .green
        
        
        //MARK: Handlers begin
        
        leftJoystick.startHandler = { [unowned self] in
            
            
//            self.hunter.run(SKAction.sequence([SKAction.scale(to: 0.5, duration: 0.5), SKAction.scale(to: 1, duration: 0.5)]))
        }
        
        leftJoystick.trackingHandler = { [unowned self] data in
            
            guard !self.gameOverFlag else { return }
            self.hunter.position = CGPoint(x: self.hunter.position.x + (data.velocity.x * 0.12), y: self.hunter.position.y + (data.velocity.y * 0.12))
        }
        
        leftJoystick.stopHandler = { [unowned self] in
//            self.hunter.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.5), SKAction.scale(to: 1, duration: 0.5)]))
        }
    }
    
    func spawnEnemy() {
        let bearNode = SKSpriteNode(imageNamed: "bear")
        bearNode.name = "bear"
        addChild(bearNode)
        bearNode.size = hunter.size
        bearNode.physicsBody = SKPhysicsBody(circleOfRadius: bearNode.size.width/2)
        bearNode.physicsBody?.affectedByGravity = false
        bearNode.physicsBody?.isDynamic = true
        bearNode.physicsBody?.collisionBitMask = PhysicsCategory.Monster
        let a = arc4random()%UInt32(size.width)
        let b = UInt32(size.width)/2
        
        let xPos = Int(Double(a) - Double(b))
        let yPos = Int(Double(arc4random()%UInt32(size.height)) - Double(UInt32(size.height)/2))
        bearNode.position = CGPoint(x: xPos, y: yPos)
        bearNode.run(SKAction.sequence([SKAction.move(to: hunter.position, duration: 5), SKAction.removeFromParent()]))
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
        shootingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(shoot), userInfo: nil, repeats: true)
    }
    
    func shoot() {
        let granadeNode = SKSpriteNode(imageNamed: "bee")
        granadeNode.name = "bee"
        
        addChild(granadeNode)
        granadeNode.size = hunter.size
        granadeNode.setScale(0.4)
        granadeNode.physicsBody = SKPhysicsBody(circleOfRadius: granadeNode.size.width/2)
        granadeNode.physicsBody?.isDynamic = true
        granadeNode.physicsBody?.affectedByGravity = false
        granadeNode.physicsBody?.contactTestBitMask = PhysicsCategory.All
        granadeNode.physicsBody?.collisionBitMask = PhysicsCategory.Projectile
        
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
    
    public func didBegin(_ contact: SKPhysicsContact) {
        let validNames = ["bear", "bee"]
        let gameOverNames = ["bear", "hunter"]
        if validNames.contains(contact.bodyA.node?.name ?? "ds") &&
            validNames.contains(contact.bodyB.node?.name ?? "ds") {
            contact.bodyA.node?.removeAllActions()
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeAllActions()
            
            let blowUp = SKAction.customAction(withDuration: 0.05) { (node, dura) in
                let meatNode = SKSpriteNode(imageNamed: "explosion")
                meatNode.position = node.position
                self.addChild(meatNode)
                meatNode.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeOut(withDuration: 1) , SKAction.removeFromParent()]))
            }
            contact.bodyB.node?.run(SKAction.sequence([blowUp, SKAction.removeFromParent()]))

            print("mish + bee = LOVE")
        } else if gameOverNames.contains(contact.bodyA.node?.name ?? "ds") &&
                gameOverNames.contains(contact.bodyB.node?.name ?? "ds") {
            gameOver()
        }
    }
    
    func gameOver() {
        print("GAME OVER")
        gameOverFlag = true
        medvedTimer?.invalidate()
        removeAllChildren()
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, won: false)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
