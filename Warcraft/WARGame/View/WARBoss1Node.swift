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
    /// 子弹角度变化量
    fileprivate var _bulletsAnglePadding: CGFloat = 0
    
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
        //  扇形子弹
        let waitAngleShootAction = SKAction.wait(forDuration: 0.5)
        let creatAngleAction = SKAction.run {
            self._creatBullets1(origin_position: CGPoint(x: self.position.x+50, y: self.position.y - self.size.height/2))
            self._creatBullets1(origin_position: CGPoint(x: self.position.x-50, y: self.position.y - self.size.height/2))
        }
        //  扇形子弹
        let angleBulletAction = SKAction.repeat(SKAction.sequence([waitAngleShootAction, creatAngleAction]), count: 50)
        
        //  跟踪子弹
        let creatTargetBulletsAction = SKAction.run {
            let origin1 = CGPoint(x: self.position.x + 50, y: self.position.y)
            let origin2 = CGPoint(x: self.position.x - 50, y: self.position.y)
            let target = WARPlayerPlaneNode.sharedInstance().position
            self._creatBullets2(origin_position: origin1, target_position: target)
            self._creatBullets2(origin_position: origin2, target_position: target)
        }
        let waitTargetAction = SKAction.wait(forDuration: 0.2)
        let targetBulletAction = SKAction.repeat(SKAction.sequence([waitTargetAction, creatTargetBulletsAction]), count: 50)
        
        run(SKAction.repeatForever(SKAction.sequence([targetBulletAction, angleBulletAction])))
    }
    
    /// 创建子弹 带移动动画  扇形散弹
    ///
    /// - Parameters:
    ///   - origin_position: 初始位置
    ///   - firstOriginAngle: 初始角度
    fileprivate func _creatBullets1(origin_position: CGPoint) {
        // 子弹位置
        let position_bullets = origin_position
        //  每一波子弹个数
        let count = 5
        //  子弹扇形夹角  90度
        let sectorAngle = CGFloat(M_PI)/2
        //  每条单线 夹角
        let avgAngle = sectorAngle / CGFloat(count)
        //  第一条单线的初始角度
        let firstOriginAngle = (CGFloat(M_PI) - sectorAngle) / 2
        //  子弹射程
        let bulletRange = position.y
        
        for index in 0...count {
            // 实例化子弹
            let bulletNode = SKSpriteNode(texture: _bulletTexture)
            bulletNode.preparePhysicsBody(type: .boss)
            bulletNode.position = origin_position
            parent?.addChild(bulletNode)
            
            //  子弹动画
            //  当前子弹角度
            let angle = firstOriginAngle+avgAngle*CGFloat(index)
            bulletNode.zRotation = angle + CGFloat(M_PI_2)
            
            let x = position_bullets.x - bulletRange * cos(angle)
            let y = position_bullets.y - bulletRange * sin(angle)
            let moveAction = SKAction.move(to: CGPoint(x: x, y: y), duration: 4)
            let removeAction = SKAction.run {
                bulletNode.removeFromParent()
            }
            
            bulletNode.run(SKAction.sequence([moveAction, removeAction]))
            
        }
    }
    
    /// 跟踪导弹
    ///
    /// - Parameters:
    ///   - origin_position: 初始位置
    ///   - target_position: 目标位置
    fileprivate func _creatBullets2(origin_position: CGPoint, target_position: CGPoint) {
        //  子弹
        let bulletNode = SKSpriteNode(texture: _bulletTexture)
        bulletNode.preparePhysicsBody(type: .boss)
        bulletNode.position = origin_position
        parent?.addChild(bulletNode)
        
        //  动画
        /// 目标位置和当前位置 计算距离差 从而计算子弹移动时间
        let dx: Double = Double(target_position.x - origin_position.x)
        let dy: Double = Double(target_position.y - origin_position.y)
        let distance = sqrt(dx * dx + dy * dy)
        
        
        let moveAction = SKAction.move(to: target_position, duration: distance/200)
        let removeAction = SKAction.run {
            bulletNode.removeFromParent()
        }
        
        bulletNode.run(SKAction.sequence([moveAction, removeAction]))
    }
    
}
