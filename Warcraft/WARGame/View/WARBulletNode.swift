//
//  WARBulletNode.swift
//  Warcraft
//
//  Created by kokozu on 2017/3/14.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

enum WARBulletNodeType {
    case player
    case enemy
    case boss
}

extension SKNode {
    
    //  名称
    var BulletNodeName: String { return "BulletNode" }
    
    //MARK: Public Methods
    
    /// 准备物理属性
    ///
    /// - Parameter type: 子弹类型
    func preparePhysicsBody(type: WARBulletNodeType) {
        //  物理属性
        physicsBody = SKPhysicsBody(rectangleOf: self.frame.size)
        physicsBody?.allowsRotation = false
//        physicsBody?.isDynamic = false
        
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
            zRotation = CGFloat(Double.pi)
            break
        case .boss:
            physicsBody?.categoryBitMask = BulletsWithEnemyBitMask
            physicsBody?.collisionBitMask = PlayerBitMask
            physicsBody?.contactTestBitMask = PlayerBitMask
            zRotation = CGFloat(Double.pi)
            break
        }
    }
    
    /// 子弹移动
    func move(type: WARBulletNodeType) {
        switch type {
        case .player:
            //  向上移动
            let actionMove = SKAction.moveBy(x: 0, y: UIScreen.main.bounds.height, duration: 1)
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
