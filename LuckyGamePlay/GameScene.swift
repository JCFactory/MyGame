//
//  GameScene.swift
//  LuckyGamePlay
//
//  Created by Jacqueline on 23.05.17.
//  Copyright © 2017 Jackys Code Factory. All rights reserved.
//

import SpriteKit
import GameplayKit

let BlockSize:CGFloat=20.0

//#1 Konstante, die das Minimum der Geschwindigkeit der Objekte festlegt (600 Millisekunden)
let TickLengthLevelOne = TimeInterval(600)

class GameScene: SKScene {
    
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)
    
//#2 Variable tickLengthMillis is the curent length of GameScene, lastTick is the last experienced tick

    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    var lastTick:NSDate?
    
    var textureCache = Dictionary<String,SKTexture>()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
       
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        // Called before each frame is rendered
        
        
       //#3 guard checks the conditions which follow in Swift
        guard let lastTick = lastTick else{
            return
        }
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis{
            self.lastTick = NSDate()
            tick?() //is there already a tick()? if yes, invoe it with no parameters
        }
        
    }
    
    //#4 provided accessor methods to let external classes start and stop the ticking process
    func startTicking(){
        lastTick = NSDate()
    }
    
    func stopTicking(){
        lastTick = nil
    }
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPointMake(x,y)
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            // #10
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            // #11
            sprite.position = pointForColumn(column: block.column, row:block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            // #12
            let moveAction = SKAction.move(to: pointForColumn(column: block.column, row: block.row), duration: TimeInterval(0.2))
            moveAction.timingMode = .easeOut
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            fadeInAction.timingMode = .easeOut
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    func movePreviewShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
            moveToAction.timingMode = .easeOut
            sprite.run(
                SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion: {})
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
            moveToAction.timingMode = .easeOut
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
    
    
}
