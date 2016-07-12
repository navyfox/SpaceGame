
//
//  GameScene.swift
//  SpaceGame
//
//  Created by p1us on 26.08.15.
//  Copyright (c) 2015 Ivan Akulov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate  {

    let spaceShipCategory: UInt32 = 0x1 << 0
    let asteroidCategory: UInt32 = 0x1 << 1

    // создаем свойства
    var background: SKSpriteNode!
    var spaceShip: SKSpriteNode!
    var score = 0
    var scoreLabel: SKLabelNode!
    var asteroidLayer: SKNode!
    var gameIsPaused: Bool = false
    var starLayer: SKNode!

    func pauseTheGame() {
        gameIsPaused = true
        self.asteroidLayer.paused = true
        physicsWorld.speed = 0
        self.starLayer.paused = true
    }

    func pauseButtonPressed(sender: AnyObject) {
        if !gameIsPaused {
            pauseTheGame()
        } else {
            unpauseTheGame()
        }
    }

    func unpauseTheGame(){
        gameIsPaused = false
        self.asteroidLayer.paused = false
        self.starLayer.paused = false
        physicsWorld.speed = 1
    }

    func resetTheGame() {
        score = 0
        scoreLabel.text = "Score: \(score)"
        gameIsPaused = false
        self.asteroidLayer.paused = false
        physicsWorld.speed = 1
    }


    override func didMoveToView(view: SKView) {

        srand48(time(nil))

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8)

        //создаем фон
        let width = UIScreen.mainScreen().bounds.size.width  //frame.size.width
        let height = UIScreen.mainScreen().bounds.size.height

        background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: width / 2, y: height / 2)
        background.size = CGSize(width: width + 8, height: height + 12)
        addChild(background)

        //слой звезд
        let starsPatch = NSBundle.mainBundle().pathForResource("stars", ofType: "sks")!
        let starsEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(starsPatch) as! SKEmitterNode

        starsEmitter.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetHeight(frame))
        starsEmitter.particlePositionRange.dx = CGRectGetWidth(frame)
        starsEmitter.advanceSimulationTime(10)

        starLayer = SKNode()
        starLayer.zPosition = 1
        addChild(starLayer)

        starLayer.addChild(starsEmitter)

        //Создаем космический корабль и определяем начальную позицию на экране
        spaceShip = SKSpriteNode(imageNamed: "spaceShip")
        spaceShip.position = CGPoint(x: 200, y: 200)
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.dynamic = false

        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory

        addChild(spaceShip)

        //Генерируем астероиды
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 2
        addChild(asteroidLayer)

        let asteroidCreateAction = SKAction.runBlock { () -> Void in
            let asteroid = self.createAnAsteroid()
            self.asteroidLayer.addChild(asteroid)
        }

        let asteroidPerSecond: Double = 1
        let asteroidCreateDeley = SKAction.waitForDuration(1.0 / asteroidPerSecond, withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreateAction, asteroidCreateDeley])
        let asteroidRunAction = SKAction.repeatActionForever(asteroidSequenceAction)
        self.asteroidLayer.runAction(asteroidRunAction)

        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - scoreLabel.calculateAccumulatedFrame().height - 15)
        addChild(scoreLabel)

        background.zPosition = 0
        spaceShip.zPosition = 3
        scoreLabel.zPosition = 4
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameIsPaused {
            if let touch = touches.first {
                // определяем точку прикосновения с экраном
                let touchLocation = touch.locationInNode(self)

                let distance = distanceCalc(spaceShip.position, b: touchLocation)
                let speed: CGFloat = 500
                let time = timeToTravelDistance(distance, speed: speed)
                let moveAction = SKAction.moveTo(touchLocation, duration: time)
                moveAction.timingMode = SKActionTimingMode.EaseInEaseOut

                spaceShip.runAction(moveAction)

                let bgMoveAction = SKAction.moveTo(CGPoint(x: -touchLocation.x / 100 + frame.size.width / 2, y: -touchLocation.y / 100 + frame.size.height / 2 ), duration: time)
                background.runAction(bgMoveAction)
                
            }
        }
    }

    func distanceCalc(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
    }

    func timeToTravelDistance(distance: CGFloat, speed: CGFloat) -> NSTimeInterval {
        let time = distance / speed
        return NSTimeInterval(time)
    }


    func createAnAsteroid() -> SKSpriteNode{

        let asteroidImageArray = ["asteroid", "asteroid2"]
        let randomIndex = Int(arc4random()) % asteroidImageArray.count

        let asteroid = SKSpriteNode(imageNamed: asteroidImageArray[randomIndex])
        asteroid.zPosition = 2

        //меняем масштаб астеройдов в пределах 0.2-0.5 от их исходного размера
        //asteroid.setScale = 0.5 // as option
        let randomScale = CGFloat(arc4random() % 4 + 2) / 10

        asteroid.xScale = randomScale
        asteroid.yScale = randomScale

        //устанавливаем позицию образования астеройдов
        asteroid.position.x = CGFloat(arc4random()) % frame.size.width
        asteroid.position.y = frame.size.height + asteroid.size.height

        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.name = "asteroid"

        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.collisionBitMask = spaceShipCategory | asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = spaceShipCategory

        asteroid.physicsBody?.angularVelocity = CGFloat(drand48() * 2 - 1) * 3
        let asteroidSpeedX: CGFloat = 100
        asteroid.physicsBody?.velocity.dx = CGFloat(drand48() * 2 - 1) * asteroidSpeedX

        return asteroid

    }

    override func update(currentTime: NSTimeInterval) {

        //works 60 times per second
        //    let asteroid = createAnAsteroid()
        //    asteroid.zPosition = 2
        //    addChild(asteroid)

    }


    override func didSimulatePhysics() {
        asteroidLayer.enumerateChildNodesWithName("asteroid") { (asteroid: SKNode, stop: UnsafeMutablePointer<ObjCBool>) in
            if asteroid.position.y < 0 {
                asteroid.removeFromParent()

                self.score += 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask == asteroidCategory {
            self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
    }
}