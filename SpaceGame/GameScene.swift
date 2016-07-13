//
//  GameScene.swift
//  SpaceGame
//
//  Created by Игорь Михайлович Ракитянский on 13.07.16.
//  Copyright (c) 2016 Игорь Михайлович Ракитянский. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate  {

    let spaceShipCategory: UInt32 = 0x1 << 0  //0000000.01
    let asteroidCategory: UInt32 = 0x1 << 1   //000000..10

    //слой космического корабля
    var spaceShipLayer: SKNode!

    // создаем свойства
    var spaceShip: SKSpriteNode!
    var background: SKSpriteNode!

    var score = 0
    var scoreLabel: SKLabelNode!


    //слой астеройдов
    var asteroidLayer: SKNode!

    //слой звезд
    var starsLayer: SKNode!

    //индикатор паузы игры
    var gameIsPaused: Bool = false

    //функции паузы/снятия пазуы/резета
    func pauseTheGame() {

        gameIsPaused = true

        self.asteroidLayer.paused = true
        physicsWorld.speed = 0

        self.starsLayer.paused = true

    }

    func pauseButtonPressed(sender: AnyObject) {

        if !gameIsPaused {
            pauseTheGame()
        } else {
            unpauseTheGame()
        }

    }

    func unpauseTheGame() {

        gameIsPaused = false

        self.asteroidLayer.paused = false
        physicsWorld.speed = 1

        self.starsLayer.paused = false

    }

    func resetTheGame(){

        score = 0
        scoreLabel.text = "Score: \(score)"

        gameIsPaused = false

        self.asteroidLayer.paused = false
        self.starsLayer.paused = false
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

        //создаем слой звезд

        let starsPath = NSBundle.mainBundle().pathForResource("stars", ofType: "sks")!
        let starsEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(starsPath) as! SKEmitterNode

        starsEmitter.zPosition = 1
        starsEmitter.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetHeight(frame))
        starsEmitter.particlePositionRange.dx = CGRectGetWidth(frame)
        starsEmitter.advanceSimulationTime(10)

        //addChild(starsEmitter)

        starsLayer = SKNode()
        starsLayer.zPosition = 1
        addChild(starsLayer)

        starsLayer.addChild(starsEmitter)

        //Создаем космический корабль и определяем начальную позицию на экране
        spaceShip = SKSpriteNode(imageNamed: "spaceShip")
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.dynamic = false
        spaceShip.zPosition = 1

        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory

        let colorAction1 = SKAction.colorizeWithColor(UIColor.yellowColor(), colorBlendFactor: 1, duration: 1)
        let colorAction2 = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 0, duration: 1)
        let colorSequenceAnimation = SKAction.sequence([colorAction1, colorAction2])
        let colorActionRepeat = SKAction.repeatActionForever(colorSequenceAnimation)
        spaceShip.runAction(colorActionRepeat)

        //создаем слой космического корабля и огня
        spaceShipLayer = SKNode()
        spaceShipLayer.addChild(spaceShip)
        spaceShipLayer.zPosition = 3
        spaceShip.zPosition = 1
        spaceShipLayer.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetHeight(frame) / 4)
        addChild(spaceShipLayer)


        //слой огня
        let firePath = NSBundle.mainBundle().pathForResource("fire", ofType: "sks")
        let fireEmiter = NSKeyedUnarchiver.unarchiveObjectWithFile(firePath!) as! SKEmitterNode
        fireEmiter.zPosition = 0
        fireEmiter.position.y = -40
        fireEmiter.targetNode = self
        spaceShipLayer.addChild(fireEmiter)




        //Генерируем астеройды
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 2
        addChild(asteroidLayer)

        let asteroidCreateAction = SKAction.runBlock { () -> Void in
            let asteroid = self.createAnAsteroid()
            self.asteroidLayer.addChild(asteroid)
        }

        let asteroidsPerSecond: Double = 1
        let asteroidCreationDelay = SKAction.waitForDuration(1.0 / asteroidsPerSecond, withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreateAction, asteroidCreationDelay])
        let asteroidRunAction = SKAction.repeatActionForever(asteroidSequenceAction)

        self.asteroidLayer.runAction(asteroidRunAction)

        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - scoreLabel.calculateAccumulatedFrame().height - 15)
        addChild(scoreLabel)

        background.zPosition = 0
        scoreLabel.zPosition = 4
    }

    //функция, срабатывающая при касании экрана
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        if !gameIsPaused {
            if let touch = touches.first {

                // определяем точку прикосновения с экраном
                let touchLocation = touch.locationInNode(self)

                //вычисляем дистанцию до точки прикосновения и время полета до точки прикосновения
                let distance = distanceCalc(spaceShipLayer.position, b: touchLocation)
                let speed: CGFloat = 600
                let time = timeToTravelDistance(distance, speed: speed)
                let moveAction = SKAction.moveTo(touchLocation, duration: time)
                moveAction.timingMode = SKActionTimingMode.EaseInEaseOut

                spaceShipLayer.runAction(moveAction)

                let bgMoveAction = SKAction.moveTo(CGPoint(x: -touchLocation.x / 80 + frame.size.width / 2, y: -touchLocation.y / 80 + frame.size.height / 2), duration: time)
                background.runAction(bgMoveAction)

                let starMoveAction = SKAction.moveTo(CGPoint(x: -touchLocation.x / 60, y: -touchLocation.y / 60), duration: time)
                starsLayer.runAction(starMoveAction)
            }
        }
    }

    //функция подсчета дистанции
    func distanceCalc(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
    }

    //функция подсчета времени полета
    func timeToTravelDistance(distance: CGFloat, speed: CGFloat) -> NSTimeInterval {
        let time = distance / speed
        return NSTimeInterval(time)
    }

    func createAnAsteroid() -> SKSpriteNode{

        let asteroidImageArray = ["asteroid", "asteroid2"]
        let randomIndex = Int(arc4random()) % asteroidImageArray.count
        let asteroid = SKSpriteNode(imageNamed: asteroidImageArray[randomIndex])

        //меняем масштаб астеройдов в пределах 0.2-0.5 от их исходного размера
        let randomScale = CGFloat(arc4random() % 4 + 2) / 10
        asteroid.xScale = randomScale
        asteroid.yScale = randomScale

        //устанавливаем позицию образования астеройдов
        asteroid.position.x = CGFloat(arc4random()) % frame.size.width
        asteroid.position.y = frame.size.height + asteroid.size.height

        //присваиваем астеройду физическое тело
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

    //срабатывает 60 раз в секунду (60fps)
    override func update(currentTime: NSTimeInterval) {

        //    let asteroid = createAnAsteroid()
        //    addChild(asteroid)

    }


    override func didSimulatePhysics() {
        
        asteroidLayer.enumerateChildNodesWithName("asteroid") { (asteroid: SKNode, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if asteroid.position.y < 0 {
                asteroid.removeFromParent()
                
                self.score += 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }
    
    //функция столкновения двух тел
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask == asteroidCategory {
            self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
        }
        
        print("asteroid hits spaceship")
        
    }
    
    
    func didEndContact(contact: SKPhysicsContact) {
        
    }
}