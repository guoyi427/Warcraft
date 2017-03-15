//
//  WARBoss1Node.swift
//  Warcraft
//
//  Created by kokozu on 2017/3/15.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

class WARBoss1Node: SKSpriteNode {
    
    /// 飞机纹理
    fileprivate let _bossTexture = SKTexture(image: #imageLiteral(resourceName: "plane3"))
    /// 子弹纹理
    fileprivate let _bulletTexture = SKTexture(image: #imageLiteral(resourceName: "bullets"))
    
    init() {
        super.init(texture: _bossTexture, color: SKColor.clear, size: CGSize(width: 150, height: 150))
        
        //  基础属性
        position = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height + size.height/2)
        zRotation = CGFloat(M_PI)
        
        //  物理属性
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height*0.3))//扁长不露馅，用纹理获取不规则图片过于消耗性能 所以直接用固定扁长size
        physicsBody?.categoryBitMask = EnemyBitMask
        physicsBody?.collisionBitMask = BulletsBitMask
        physicsBody?.contactTestBitMask = BulletsBitMask
        physicsBody?.allowsRotation = false

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public Methods
    
    func show() {
        //  出场动画
        let moveInAction = SKAction.moveTo(y: UIScreen.main.bounds.height - size.height, duration: 2)
        let waitAction = SKAction.run {
            self._shootBullets()
        }
        run(SKAction.sequence([moveInAction, waitAction]))
    }

    //MARK: Private Methods
    
    /// 控制子弹发射
    fileprivate func _shootBullets() {
        let waitShootAction = SKAction.wait(forDuration: 0.2)
        let creatAction = SKAction.run {
            self._creatBullets1()
        }
        
        run(SKAction.repeatForever(SKAction.sequence([waitShootAction, creatAction])))
    }
    
    /// 创建子弹 带移动动画
    fileprivate func _creatBullets1() {
        // 子弹位置
        let position_bullets = CGPoint(x: position.x, y: position.y - size.height/2 - 20)
        //  每一波子弹个数
        let count = 20
        //  子弹扇形夹角  60度
        let sectorAngle = CGFloat(M_PI)/3
        //  每条单线 夹角
        let avgAngle = sectorAngle / 20
        //  第一条单线的初始角度
        let firstOriginAngle = (CGFloat(M_PI) - sectorAngle) / 2
        //  子弹射程
        let bulletRange = position.y
        
        for index in 0...count {
            // 实例化子弹
            let bulletNode = WARBulletNode(type: .boss, texture: _bulletTexture)
            bulletNode.position = CGPoint(x: position.x, y: position.y - size.height/2 - 20)
            parent?.addChild(bulletNode)
            
            //  子弹动画
            //  当前子弹角度
            let angle = firstOriginAngle+avgAngle*CGFloat(index)
            let x = position_bullets.x - bulletRange * cos(angle)
            let y = position_bullets.y - bulletRange * sin(angle)
            let moveAction = SKAction.move(to: CGPoint(x: x, y: y), duration: 4)
            let removeAction = SKAction.run {
                bulletNode.removeFromParent()
            }
            
            bulletNode.run(SKAction.sequence([moveAction, removeAction]))
            
        }
    }
    
    
}
