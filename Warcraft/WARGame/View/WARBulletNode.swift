//
//  WARBulletNode.swift
//  Warcraft
//
//  Created by kokozu on 2017/3/14.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

class WARBulletNode: SKSpriteNode {
    
    enum WARBulletNodeType {
        case player
        case enemy
        case boss
    }
    //  名称
    let BulletNodeName = "BulletNode"
    /// 屏幕size
    fileprivate let ScreenSize = UIScreen.main.bounds.size
    
    var type: WARBulletNodeType = .enemy
    
    
    init(type: WARBulletNodeType, texture: SKTexture) {
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        
        self.name = BulletNodeName
        self.type = type
        //  物理属性
        physicsBody = SKPhysicsBody(rectangleOf: size)

        switch type {
        case .player:
            physicsBody?.categoryBitMask = BulletsBitMask
            physicsBody?.collisionBitMask = EnemyBitMask
            physicsBody?.contactTestBitMask = EnemyBitMask
            break
        case .enemy:
            physicsBody?.categoryBitMask = BulletsWithEnemyBitMask
            physicsBody?.collisionBitMask = PlayerBitMask
            physicsBody?.contactTestBitMask = PlayerBitMask
            zRotation = CGFloat(M_PI)
            break
        case .boss:
            physicsBody?.categoryBitMask = BulletsWithEnemyBitMask
            physicsBody?.collisionBitMask = PlayerBitMask
            physicsBody?.contactTestBitMask = PlayerBitMask
            zRotation = CGFloat(M_PI)
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public Methods
    
    /// 子弹移动
    func move() {
        switch type {
        case .player:
            //  向上移动
            let actionMove = SKAction.moveBy(x: 0, y: ScreenSize.height, duration: 1)
            let actionDone = SKAction.run {
                self.removeFromParent()
            }
            run(SKAction.sequence([actionMove, actionDone]))
            break
        case .enemy:
            //  向下移动
            let actionMove = SKAction.moveBy(x: 0, y: 0, duration: 1)
            let actionDone = SKAction.run {
                self.removeFromParent()
            }
            run(SKAction.sequence([actionMove, actionDone]))
            break
        default:
            break
        }
    }
    
}
