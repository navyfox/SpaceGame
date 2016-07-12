//
//  GameScene.swift
//  SpaceGame
//
//  Created by p1us on 26.08.15.
//  Copyright (c) 2015 Ivan Akulov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene  {
  
  // создаем свойства
  var spaceShip: SKSpriteNode!
  var background: SKSpriteNode!
  
  override func didMoveToView(view: SKView) {
    
    //создаем фон
    let width = UIScreen.mainScreen().bounds.size.width  //frame.size.width
    let height = UIScreen.mainScreen().bounds.size.height
    
    background = SKSpriteNode(imageNamed: "background")
    background.position = CGPoint(x: width / 2, y: height / 2)
    background.size = CGSize(width: width, height: height)
    addChild(background)
    
    //Создаем космический корабль и определяем начальную позицию на экране
    spaceShip = SKSpriteNode(imageNamed: "spaceShip")
    spaceShip.position = CGPoint(x: 200, y: 200)
    
    spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
    spaceShip.physicsBody?.dynamic = false
    
    addChild(spaceShip)
    
    //Генерируем астероиды
    let asteroidCreateAction = SKAction.runBlock { () -> Void in
        let asteroid = self.createAnAsteroid()
        self.addChild(asteroid)
    }
    
    let asteroidCreateDeley = SKAction.waitForDuration(1.0, withRange: 0.5)
    let asteroidSequenceAction = SKAction.sequence([asteroidCreateAction, asteroidCreateDeley])
    let asteroidRunAction = SKAction.repeatActionForever(asteroidSequenceAction)
    runAction(asteroidRunAction)
    
    background.zPosition = 0
    spaceShip.zPosition = 1
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    if let touch = touches.first {
        // определяем точку прикосновения с экраном
        let touchLocation = touch.locationInNode(self)
        
        let distance = distanceCalc(spaceShip.position, b: touchLocation)
        let speed: CGFloat = 500
        let time = timeToTravelDistance(distance, speed: speed)
        let moveAction = SKAction.moveTo(touchLocation, duration: time)
        moveAction.timingMode = SKActionTimingMode.EaseInEaseOut
        
        spaceShip.runAction(moveAction)
      
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
    
    let asteroid = SKSpriteNode(imageNamed: "asteroid2")
    
    //меняем масштаб астеройдов в пределах 0.2-0.5 от их исходного размера
    //asteroid.setScale = 0.5 // as option
    let randomScale = CGFloat(arc4random() % 4 + 2) / 10
    
    asteroid.xScale = randomScale
    asteroid.yScale = randomScale
    
    //устанавливаем позицию образования астеройдов
    asteroid.position.x = CGFloat(arc4random()) % frame.size.width
    asteroid.position.y = frame.size.height + asteroid.size.height
    
    asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
    
    
    return asteroid
    
  }
  
  override func update(currentTime: NSTimeInterval) {
    
    //works 60 times per second
//    let asteroid = createAnAsteroid()
//    asteroid.zPosition = 2
//    addChild(asteroid)
    
  }
}