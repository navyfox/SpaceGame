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
    
    addChild(spaceShip)
    
    background.zPosition = 0
    spaceShip.zPosition = 1
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    if let touch = touches.first {
      
      // определяем точку прикосновения с экраном
      let touchLocation = touch.locationInNode(self)
      
      let moveAction = SKAction.moveTo(touchLocation, duration: 1)
      moveAction.timingMode = SKActionTimingMode.EaseInEaseOut
      
      spaceShip.runAction(moveAction)
      
    }
  }
  
  func createAnAsteroid() -> SKSpriteNode{
    
    let asteroid = SKSpriteNode(imageNamed: "asteroid2")
    
    //меняем масштаб астеройдов в пределах 0.2-0.5 от их исходного размера
    //asteroid.setScale = 0.5 // as option
    asteroid.xScale = 0.5
    asteroid.yScale = 0.5
    
    //устанавливаем позицию образования астеройдов
    asteroid.position.x = CGFloat(arc4random()) % frame.size.width
    asteroid.position.y = frame.size.height
    
    return asteroid
    
  }
  
  override func update(currentTime: NSTimeInterval) {
    
    //works 60 times per second
    let asteroid = createAnAsteroid()
    asteroid.zPosition = 2
    addChild(asteroid)
    
  }
}