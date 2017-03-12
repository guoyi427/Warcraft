//
//  WAREnemysEmitter.swift
//  Warcraft
//
//  Created by 郭毅 on 2017/3/12.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import Foundation
import SpriteKit

class WAREnemysEmitter:NSObject {
    
    static let sharedInstance = WAREnemysEmitter()
    fileprivate let _enemyTexture = SKTexture(image: #imageLiteral(resourceName: "plane3"))
    
    
    func pushEnemy(gameScene: SKScene) {
        let creatEnemy = SKAction.run {
            self._creatEnemy(gameScene: gameScene)
        }
        let waitNext = SKAction.wait(forDuration: 0.5)
        
        let creatEnemyAction = SKAction.repeat(SKAction.sequence([creatEnemy, waitNext]), count: 10)
        let waitPush = SKAction.wait(forDuration: 5)
        
        
        gameScene.run(SKAction.repeatForever(SKAction.sequence([creatEnemyAction, waitPush])))
    }
    
    fileprivate func _creatEnemy(gameScene: SKScene) {
    
        let enemyNode = WARPlaneSpriteNode(blood: 3, position: CGPoint(x: gameScene.size.width - 50, y: gameScene.size.height))
        /*
        let enemyNode = SKSpriteNode(texture: _enemyTexture)
        enemyNode.position = CGPoint(x: gameScene.size.width - 50, y: gameScene.size.height)
        enemyNode.zRotation = CGFloat(M_PI)
        
        //  物理属性
        enemyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemyNode.size.width, height: enemyNode.size.height*0.3))//扁长不露馅，用纹理获取不规则图片过于消耗性能 所以直接用固定扁长size
        enemyNode.physicsBody?.categoryBitMask = EnemyBitMask
        enemyNode.physicsBody?.collisionBitMask = BulletsBitMask
        enemyNode.physicsBody?.contactTestBitMask = BulletsBitMask
        enemyNode.physicsBody?.allowsRotation = false
         */
        gameScene.addChild(enemyNode)

        //  向下移动
        let actionMove = SKAction.init(named: "EnemyQueue1")
        let actionDone = SKAction.run {
            enemyNode.removeFromParent()
        }
        enemyNode.run(SKAction.sequence([actionMove!, actionDone]))
    }
    
}
