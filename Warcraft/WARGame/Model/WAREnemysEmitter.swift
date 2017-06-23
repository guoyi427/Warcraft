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
        gameScene.addChild(enemyNode)

        //  向下移动
        let actionMove = SKAction.init(named: "EnemyQueue1")
        let actionDone = SKAction.run {
            enemyNode.removeFromParent()
        }
        enemyNode.run(SKAction.sequence([actionMove!, actionDone]))
    }
    
}
