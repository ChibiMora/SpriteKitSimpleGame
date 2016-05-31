//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Crystal Mora on 1/20/16.
//  Copyright (c) 2016 Crystal Mora. All rights reserved.
//

import SpriteKit

struct PhysicsCategory{
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Monster: UInt32 = 0b01
    static let Projectile: UInt32 = 0b10
    
}

func + (left: CGPoint, right:CGPoint) -> CGPoint{
    
    return CGPoint(x:left.x+right.x, y:left.y+right.y)
}

func - (left: CGPoint, right:CGPoint) -> CGPoint{
    
    return CGPoint(x:left.x-right.x, y:left.y-right.y)
}

func * (point: CGPoint, scalar:CGFloat) -> CGPoint{
    
    return CGPoint(x:point.x*scalar, y:point.y*scalar)
}

func / (point: CGPoint, scalar:CGFloat) -> CGPoint{
    
    return CGPoint(x:point.x/scalar, y:point.y/scalar)
}

func sqrt(a: CGFloat) -> CGFloat{
    return CGFloat(sqrtf(Float(a)))
}

extension CGPoint {
    func length () -> CGFloat{
        return sqrt(x*x + y*y)
    }
    
    func normalizedd() ->CGPoint{
        return self/length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "Player")
    var score = 0
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = SKColor.blueColor()
        player.position = CGPoint(x:size.width*0.1, y:size.height*0.5)
        
        addChild(player)
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addMonster),
            SKAction.waitForDuration(1.0)])
        )
    )
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        
        physicsWorld.gravity = CGVectorMake(0,0)
        physicsWorld.contactDelegate = self
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
   
        guard let touch = touches.first else {
            return
        }
         let touchLocation = touch.locationInNode(self)
        
         let projectile = SKSpriteNode(imageNamed: "Projectile")
       
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        projectile.position = player.position
        
        projectile.xScale = 0.1
        projectile.yScale = 0.1
        
        let offset = touchLocation - projectile.position
        if offset.x < 0 {
            return
        }
        addChild(projectile)
        let direction = offset.normalizedd()
        
        let shootAmount = direction * 1000
        
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.moveTo(realDest, duration:2.0)
        let actionMoveDone = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([actionMove, actionMoveDone])
        
        projectile.runAction(sequence)
        
         let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI), duration:0.1)
        projectile.runAction(SKAction.repeatActionForever(rotateAction))
       
    

    
    }
        
        
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    func random() -> CGFloat {
        
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    
    func random(min:CGFloat, max:CGFloat) -> CGFloat {
        
        return random() * (max - min) + min
    
}
    
    func addMonster() {
       
        let someAction =
            SKAction.runBlock(){
                
                if self.score > 3 {
                    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                    let gameOverScene = GameOverScene(size: self.size, won: true)
                    self.view?.presentScene(gameOverScene, transition: reveal)
                }
        }
        
        let monster = SKSpriteNode(imageNamed: "Monster")
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        monster.physicsBody?.dynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None

    
        let actualY = random(monster.size.height/2, max:size.height-monster.size.height/2)
       
        monster.xScale = 0.5
        
        monster.yScale = 0.5
        
        monster.position = CGPoint(x:size.width+monster.size.width/2, y:actualY)
        
        addChild(monster)
        
        let actualDuration = random(CGFloat(2.0), max:CGFloat(4.0))
        
        let actionMove = SKAction.moveTo(CGPoint(x:-monster.size.width/2, y:actualY), duration: NSTimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        
        monster.runAction(SKAction.repeatActionForever(rotateAction))
        
        monster.runAction(SKAction.sequence([someAction, actionMove, actionMoveDone]))
        
       // let scaleAction = SKAction.scaleBy(CGFloat(-5), duration: 5)
        //monster.runAction(SKAction.repeatActionForever(scaleAction))


    
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("Hit")
        
        let firstBody = contact.bodyA.node as! SKSpriteNode
        let secondBody = contact.bodyB.node as! SKSpriteNode
        
        firstBody.removeFromParent()
        secondBody.removeFromParent()
        
        runAction(SKAction.playSoundFileNamed("squirrel.mp3", waitForCompletion: false))
        
        score = score + 1
        
    }
}







