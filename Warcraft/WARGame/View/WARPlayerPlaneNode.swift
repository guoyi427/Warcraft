//
//  WARPlayerPlaneNode.swift
//  Warcraft
//
//  Created by 郭毅 on 2017/3/11.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

class WARPlayerPlaneNode: SKSpriteNode {
    
    /// 屏幕size
    fileprivate let ScreenSize = UIScreen.main.bounds.size
    //  名称
    let BulletNodeName = "BulletNode"
    
    /// 子弹纹理，一次加载多次使用
    let _bulletsTexture = SKTexture(image: #imageLiteral(resourceName: "bullets"))
    /// 每分钟发射多少发炮弹
    fileprivate var BulletsShootPM: Double = 500
    /// 当前血量
    var currentBlood: Int = 100    
    
    init() {
        /// 玩家飞机纹理
        let texture = SKTexture(image: #imageLiteral(resourceName: "plane2"))
        /// 玩家飞机size
        let size_texture = texture.size()
        
        super.init(texture: texture, color: SKColor.clear, size: size_texture)
        
        position = CGPoint(x: ScreenSize.width/2, y: size_texture.height/2)

        //  物理属性
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 3, height: 3))//扁长不露馅，用纹理获取不规则图片过于消耗性能 所以直接用固定扁长size
        physicsBody?.categoryBitMask = PlayerBitMask
        physicsBody?.collisionBitMask = BulletsWithEnemyBitMask
        physicsBody?.contactTestBitMask = BulletsWithEnemyBitMask
        physicsBody?.allowsRotation = false
        
        _shootBullets()
        
        _addWingman()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Private Methods
    
    /// 发射子弹
    fileprivate func _shootBullets() {
        let creatBullet = SKAction.run {
            //  每1000分 加一个子弹发射器
            let count = WARScoreManager.sharedManager().currentScore/1000+1
            self._creatBullet(count: count)
        }
        
        let waiteShoot = SKAction.wait(forDuration: 60/BulletsShootPM)
        self.run(SKAction.repeatForever(SKAction.sequence([creatBullet, waiteShoot])))
        
    }
    
    /// 生成子弹
    fileprivate func _creatBullet(count: Int) {
        var bulletsCount = count
        
        if count>5 {
            bulletsCount = 4
        }
        let padding:CGFloat = 2.5*CGFloat(bulletsCount-1)
        
        for index in 1...bulletsCount {
            let bulletsNode = SKSpriteNode(texture: _bulletsTexture)
            
            switch bulletsCount {
            case 4:
                if index == 1 {
                    bulletsNode.position = CGPoint(x: position.x - size.width/2, y: position.y + size.height/2)
                } else if index == 3 {
                    bulletsNode.position = CGPoint(x: position.x + size.width/2, y: position.y + size.height/2)
                }
                bulletsNode.position = CGPoint(x: position.x - padding + CGFloat(index-1) * 5,
                                               y: position.y + size.height/2)
                break

            default:
                bulletsNode.position = CGPoint(x: position.x - padding + CGFloat(index-1) * 5,
                                               y: position.y + size.height/2)
            }
            
            bulletsNode.name = BulletNodeName
            
            //  物理属性
            bulletsNode.physicsBody = SKPhysicsBody(rectangleOf: bulletsNode.size)
            bulletsNode.physicsBody?.categoryBitMask = BulletsBitMask
            bulletsNode.physicsBody?.collisionBitMask = EnemyBitMask
            bulletsNode.physicsBody?.contactTestBitMask = EnemyBitMask
            
            self.parent?.addChild(bulletsNode)
            
            //  向上移动
            let actionMove = SKAction.moveBy(x: 0, y: ScreenSize.height, duration: 1)
            let actionDone = SKAction.run {
                bulletsNode.removeFromParent()
            }
            bulletsNode.run(SKAction.sequence([actionMove, actionDone]))
        }
    }
    
    /// 添加僚机
    fileprivate func _addWingman() {
        let leftWing = SKSpriteNode(color: SKColor.magenta, size: CGSize(width: 10, height: 10))
        leftWing.position = CGPoint(x: -60, y: 0)
        addChild(leftWing)
        
    }
    
    //MARK: Public Methods
    /// 掉血
    ///
    /// - Parameter damage: 伤害值
    func subBlood(damage: Int) {
        currentBlood -= damage
    }

}
