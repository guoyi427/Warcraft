//
//  WARBoss1Node.swift
//  Warcraft
//
//  Created by kokozu on 2017/3/15.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

class WARBoss1Node: SKSpriteNode {
    
    //  SpriteKit
    /// 飞机纹理
    fileprivate let _bossTexture = WARResourcesManager.sharedManager.fetchTexture(name: key_plane3)
    /// 子弹纹理
    fileprivate let _bulletTexture = WARResourcesManager.sharedManager.fetchTexture(name: key_bullets)
    fileprivate let _bulletPurpleTexture = WARResourcesManager.sharedManager.fetchTexture(name: key_bulletsPurple)
    /// 血条
    fileprivate let _bloodNode = SKSpriteNode(color: SKColor.red, size: CGSize.zero)
    
    
    //  Data
    /// 子弹角度变化量
    fileprivate var _bulletsAnglePadding: CGFloat = 0
    /// 初始血量
    var originBlood: Int = 1
    /// 当前血量
    var currentBlood: Int = 1
    
    init(blood: Int) {
        super.init(texture: _bossTexture, color: SKColor.clear, size: CGSize(width: 150, height: 150))
        
        //  基础属性
        position = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height + size.height/2)
        zRotation = CGFloat(Double.pi)
        originBlood = blood
        currentBlood = blood
        
        //  物理属性
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height*0.3))//扁长不露馅，用纹理获取不规则图片过于消耗性能 所以直接用固定扁长size
        physicsBody?.categoryBitMask = EnemyBitMask
        physicsBody?.collisionBitMask = BulletsBitMask
        physicsBody?.contactTestBitMask = BulletsBitMask
        physicsBody?.allowsRotation = false
        physicsBody?.isDynamic = false
        
        //  血条
        _prepareBloodNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare
extension WARBoss1Node {
    /// 血条
    fileprivate func _prepareBloodNode() {
        let bloodBGNode = SKSpriteNode(color: SKColor.gray, size: CGSize(width: size.width, height: 2))
        bloodBGNode.position = CGPoint(x: 0, y: -size.height/2-10)
        addChild(bloodBGNode)
        
        _bloodNode.size = bloodBGNode.size
        _bloodNode.position = CGPoint.zero
        bloodBGNode.addChild(_bloodNode)
    }
}

// MARK: - Public - Methods
extension WARBoss1Node {
    func show() {
        //  出场动画
        let moveInAction = SKAction.moveTo(y: UIScreen.main.bounds.height - size.height, duration: 2)
        let waitAction = SKAction.run {
            self._shootBullets()
        }
        run(SKAction.sequence([moveInAction, waitAction]))
    }
    
    /// 掉血
    func subBlood() {
        currentBlood = currentBlood - 1
        
        _bloodNode.xScale = CGFloat(currentBlood)/CGFloat(originBlood)
        _bloodNode.position = CGPoint(x: (1-_bloodNode.xScale)*size.width/2, y: 0)
        
        if currentBlood == 0 {
            WARScoreManager.sharedManager().addScore(score: originBlood * 100)
            removeFromParent()
        }
    }
}

// MARK: - Private - Methods
extension WARBoss1Node {
    
    /// 控制子弹发射
    fileprivate func _shootBullets() {
        //  扇形子弹
        let waitAngleShootAction = SKAction.wait(forDuration: 0.5)
        let creatAngleAction = SKAction.run {
            self._creatBullets1(origin_position: CGPoint(x: self.position.x+50, y: self.position.y))
            self._creatBullets1(origin_position: CGPoint(x: self.position.x-50, y: self.position.y))
        }
        //  扇形子弹
        let angleBulletAction = SKAction.repeat(SKAction.sequence([waitAngleShootAction, creatAngleAction]), count: 30)
        
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
        let count = 30
        //  子弹扇形夹角
        let sectorAngle = CGFloat(Double.pi)*2
        //  每条单线 夹角
        let avgAngle = sectorAngle / CGFloat(count)
        //  第一条单线的初始角度
        let firstOriginAngle = (CGFloat(Double.pi) - sectorAngle) / 2
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
            bulletNode.zRotation = angle + CGFloat(Double.pi/2.0)
            
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
        let bulletNode = SKSpriteNode(texture: _bulletPurpleTexture, size: _bulletPurpleTexture.size())
        
        bulletNode.preparePhysicsBody(type: .boss)
        bulletNode.position = origin_position
        parent?.addChild(bulletNode)
        
        //  动画
        /// 目标位置和当前位置 计算距离差 从而计算子弹移动时间
        let dx: Double = Double(origin_position.x - target_position.x)
        let dy: Double = Double(origin_position.y - target_position.y)
        
        //  角度
        let angle = -tan(dx/dy) + Double.pi
        bulletNode.zRotation = CGFloat(angle)
        
        //  消失点
        let target_dy = Double(origin_position.y)
        let target_dx = dx * (target_dy / dy)
        let dismissPoint = CGPoint(x: origin_position.x-CGFloat(target_dx), y: 0)
        
        //  移动距离
        let distance = sqrt(target_dx * target_dx + target_dy * target_dy)
        
        
        let moveAction = SKAction.move(to: dismissPoint, duration: distance/200)
        let removeAction = SKAction.run {
            bulletNode.removeFromParent()
        }
        
        bulletNode.run(SKAction.sequence([moveAction, removeAction]))
    }
}
