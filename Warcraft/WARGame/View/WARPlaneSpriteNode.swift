//
//  WARPlaneSpriteNode.swift
//  Warcraft
//
//  Created by kokozu on 2017/3/9.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

class WARPlaneSpriteNode: SKSpriteNode {
    
    /// 初始血量
    var originBlood: Int = 0
    /// 当前血量
    var currentBlood: Int = 1
    /// 敌机纹理
    fileprivate let _enemysTexture = SKTexture(image: #imageLiteral(resourceName: "plan1"))
    /// 子弹
    fileprivate let _bulletsTexture = SKTexture(image: #imageLiteral(resourceName: "bullets"))
    
    /// 血条
    fileprivate let _bloodNode = SKSpriteNode(color: SKColor.red, size: CGSize.zero)
    
    /// 屏幕尺寸
    fileprivate let ScreenSize = UIScreen.main.bounds.size
    /// 战机名称
    fileprivate let EnemyNodeName = "EnemyNode"
    
    init(blood: Int) {
        super.init(texture: _enemysTexture, color: SKColor.clear, size: _enemysTexture.size())
        currentBlood = blood
        originBlood = blood
        //  随机位置
        let x_position = arc4random()%UInt32(ScreenSize.width-size.width) + UInt32(size.width/2)
        position = CGPoint(x: CGFloat(x_position), y: ScreenSize.height-size.height)
        zRotation = CGFloat(M_PI)
        name = EnemyNodeName
        
        //  物理属性
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height*0.3))//扁长不露馅，用纹理获取不规则图片过于消耗性能 所以直接用固定扁长size
        physicsBody?.categoryBitMask = EnemyBitMask
        physicsBody?.collisionBitMask = BulletsBitMask
        physicsBody?.contactTestBitMask = BulletsBitMask
        physicsBody?.allowsRotation = false
        
        _prepareBloodNode()
        
        _shootBullet()
    }
    
    init(blood: Int, position: CGPoint) {
        super.init(texture: _enemysTexture, color: SKColor.clear, size: _enemysTexture.size())
        currentBlood = blood
        originBlood = blood
       
        self.position = position
        zRotation = CGFloat(M_PI)
        name = EnemyNodeName
        
        //  物理属性
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height*0.3))//扁长不露馅，用纹理获取不规则图片过于消耗性能 所以直接用固定扁长size
        physicsBody?.categoryBitMask = EnemyBitMask
        physicsBody?.collisionBitMask = BulletsBitMask
        physicsBody?.contactTestBitMask = BulletsBitMask
        physicsBody?.allowsRotation = false

        _prepareBloodNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 血条
    fileprivate func _prepareBloodNode() {
        let bloodBGNode = SKSpriteNode(color: SKColor.gray, size: CGSize(width: size.width, height: 5))
        bloodBGNode.position = CGPoint(x: 0, y: -size.height/2-10)
        addChild(bloodBGNode)
        
        _bloodNode.size = bloodBGNode.size
        _bloodNode.position = CGPoint.zero
        bloodBGNode.addChild(_bloodNode)
        
    }
    
    //MARK: Shoot Bullet
    fileprivate func _shootBullet() {
        
        let waitShootAction = SKAction.wait(forDuration: 1)
        let creatAction = SKAction.run {
            self._creatEnemyBullets()
        }
      
        self.run(SKAction.repeatForever(SKAction.sequence([waitShootAction, creatAction])))
    }
    
    /// 创建敌军子弹
    fileprivate func _creatEnemyBullets() {
        let bullet = SKSpriteNode(color: SKColor.white, size: CGSize(width: 5, height: 5))//SKSpriteNode(texture: _bulletsTexture)
        bullet.position = CGPoint(x: position.x, y: position.y - size.height/2 - bullet.size.height)
        bullet.zRotation = CGFloat(M_PI)
        self.parent?.addChild(bullet)
        
        //  物理属性
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = BulletsWithEnemyBitMask
        bullet.physicsBody?.collisionBitMask = PlayerBitMask
        bullet.physicsBody?.contactTestBitMask = PlayerBitMask
        
        //  子弹动画
        let moveDown = SKAction.moveBy(x: 0, y: -ScreenSize.height, duration: 2)
        let done = SKAction.run {
            bullet.removeFromParent()
        }
        
        bullet.run(SKAction.sequence([moveDown, done]))
    }
    
    //MARK: Public Methods
    
    /// 掉血
    func subBlood() {
        currentBlood = currentBlood - 1
        
        _bloodNode.xScale = CGFloat(currentBlood)/CGFloat(originBlood)
        _bloodNode.position = CGPoint(x: (1-_bloodNode.xScale)*size.width/2, y: 0)
        
        if currentBlood == 0 {
            WARScoreManager.sharedManager().addScore(score: 100)
            removeFromParent()
        }
    }
    
    
    
}
