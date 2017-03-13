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
    /// 飞机等级 默认1级
    var level: Int = 1
    
    
    /// 左 僚机
    fileprivate let _leftWings = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 10, height: 10))
    
    /// 右 僚机
    fileprivate let _rightWings = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 10, height: 10))
    
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Private Methods
    
    /// 发射子弹
    fileprivate func _shootBullets() {
        let creatBullet = SKAction.run {
            //  每1000分 加一个子弹发射器
            self.level = WARScoreManager.sharedManager().currentScore/1000+1
            self.level = 6
            self._creatBullet(count: self.level)
        }
        
        let waiteShoot = SKAction.wait(forDuration: 60/BulletsShootPM)
        self.run(SKAction.repeatForever(SKAction.sequence([creatBullet, waiteShoot])))
        
    }
    
    /// 生成子弹
    fileprivate func _creatBullet(count: Int) {
        
        for index in 1...count {
            let bulletsNode = SKSpriteNode(texture: _bulletsTexture)
            
            //  计算 position
           _calculateBulletPosition(bulletsNode: bulletsNode, bulletsCount: count, index: index)
            
            bulletsNode.name = BulletNodeName
            
            //  物理属性
            bulletsNode.physicsBody = SKPhysicsBody(rectangleOf: bulletsNode.size)
            bulletsNode.physicsBody?.categoryBitMask = BulletsBitMask
            bulletsNode.physicsBody?.collisionBitMask = EnemyBitMask
            bulletsNode.physicsBody?.contactTestBitMask = EnemyBitMask
            
            addChild(bulletsNode)
            
            //  向上移动
            let actionMove = SKAction.moveBy(x: 0, y: ScreenSize.height, duration: 1)
            let actionDone = SKAction.run {
                bulletsNode.removeFromParent()
            }
            bulletsNode.run(SKAction.sequence([actionMove, actionDone]))
        }
    }
    
    fileprivate func _calculateBulletPosition(bulletsNode: SKSpriteNode, bulletsCount: Int, index: Int) {
        //1,2,3     |||
        //4         |  ||  |
        //5         | | | | |
        //6         ||  ||  ||
        
        let padding:CGFloat = 2.5*CGFloat(bulletsCount-1)
        let defult_y = size.height/2
        
        switch bulletsCount {
        case 4:
            if index == 1 {
                bulletsNode.position = CGPoint(x: -size.width/2, y: defult_y)
            } else if index == 4 {
                bulletsNode.position = CGPoint(x: size.width/2, y: defult_y)
            } else {
                bulletsNode.position = CGPoint(x: -padding + CGFloat(index-1) * 5,
                                               y: defult_y)
            }
            break
        case 5:
            let padding_5: CGFloat = size.width/4
            bulletsNode.position = CGPoint(x: padding_5 * CGFloat(index - 1)-size.width/2, y: defult_y)
            break
        case 6:
            let padding_6: CGFloat = (size.width-15)/2
            /// 下标为 偶数是 添加一个 padding
            var evenIndexPadding: CGFloat = 5
            if index%2==1 {
                evenIndexPadding = 0
            }
            bulletsNode.position = CGPoint(x: CGFloat(index/2)*(padding_6+evenIndexPadding)-size.width/2, y: defult_y)
            break
            
        default:
            //1,2,3
            bulletsNode.position = CGPoint(x: -padding + CGFloat(index-1) * 5,
                                           y: defult_y)
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
