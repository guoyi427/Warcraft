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
    }
    //  名称
    let BulletNodeName = "BulletNode"
    /// 屏幕size
    fileprivate let ScreenSize = UIScreen.main.bounds.size
    
    var type: WARBulletNodeType = .enemy
    
    
    init(type: WARBulletNodeType, texture: SKTexture) {
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        
        name = BulletNodeName
        
        //  物理属性
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = BulletsBitMask
        physicsBody?.collisionBitMask = EnemyBitMask
        physicsBody?.contactTestBitMask = EnemyBitMask
        
        
        //  向上移动
        let actionMove = SKAction.moveBy(x: 0, y: ScreenSize.height, duration: 1)
        let actionDone = SKAction.run {
            self.removeFromParent()
        }
        run(SKAction.sequence([actionMove, actionDone]))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
