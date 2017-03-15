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
    
    /// 子弹纹理，一次加载多次使用
    let _bulletsTexture = SKTexture(image: #imageLiteral(resourceName: "bullets"))
    /// 每分钟发射多少发炮弹
    fileprivate var BulletsShootPM: Double = 500
    /// 当前血量
    var currentBlood: Int = 100
    /// 飞机等级 默认1级
    var level: Int = 1
    
    
    /// 左 僚机
    fileprivate var _leftWings: SKSpriteNode? = nil
    
    /// 右 僚机
    fileprivate var _rightWings: SKSpriteNode? = nil
    
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
            self._creatBullet(count: self.level)
        }
        
        let waiteShoot = SKAction.wait(forDuration: 60/BulletsShootPM)
        self.run(SKAction.repeatForever(SKAction.sequence([creatBullet, waiteShoot])))
        
    }
    
    /// 生成子弹
    fileprivate func _creatBullet(count: Int) {
        
        //  飞机主题子弹 最多5个子弹反射器
        let bulletsCount = count < 6 ? count : 5
        
        for index in 1...bulletsCount {
            let bulletsNode = WARBulletNode(type: .player, texture: _bulletsTexture)
            //  计算 position
           _calculateBulletPosition(bulletsNode: bulletsNode, bulletsCount: bulletsCount, index: index)
            self.parent!.addChild(bulletsNode)
            bulletsNode.move()
        }
        
        //  添加僚机
        _addWingman()
    }
    
    fileprivate func _calculateBulletPosition(bulletsNode: SKSpriteNode, bulletsCount: Int, index: Int) {
        //1,2,3     |||
        //4         |  ||  |
        //5         | | | | |
        //6         ||  ||  ||
        
        let defult_y = size.height/2
        let padding_123 = 2.5*CGFloat(bulletsCount-1)
        
        switch bulletsCount {
        case 4:
            if index == 1 {
                bulletsNode.position = CGPoint(x: -size.width/2, y: defult_y)
            } else if index == 4 {
                bulletsNode.position = CGPoint(x: size.width/2, y: defult_y)
            } else {
                bulletsNode.position = CGPoint(x: -padding_123 + CGFloat(index-1) * 5,
                                               y: defult_y)
            }
            break
        case 1,2,3:
            //1,2,3
            bulletsNode.position = CGPoint(x: -padding_123 + CGFloat(index-1) * 5,
                                           y: defult_y)
            break
            
        default:
            let padding:CGFloat = size.width/CGFloat(bulletsCount-1)
            bulletsNode.position = CGPoint(x: -size.width/2 + padding * CGFloat(index - 1), y: defult_y)
            
        }
        bulletsNode.position = CGPoint(x: bulletsNode.position.x + position.x, y: bulletsNode.position.y + position.y)
    }
    
    /// 添加僚机
    fileprivate func _addWingman() {
        if level > 5 && _leftWings == nil {
            //  左僚机
            _leftWings = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 10, height: 20))
            _leftWings?.position = CGPoint(x: -80, y: 0)
            addChild(_leftWings!)
        }
        
        if level > 6 && _rightWings == nil {
            //  右僚机 
            _rightWings = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 10, height: 20))
            _rightWings?.position = CGPoint(x: 80, y: 0)
            addChild(_rightWings!)
        }
        
        //  发射子弹 左
        if let wingman = _leftWings {
            let bullet = WARBulletNode(type: .player, texture: _bulletsTexture)
            bullet.position = CGPoint(x: position.x + wingman.position.x, y: position.y + wingman.position.y + wingman.size.height/2)
            self.parent!.addChild(bullet)
            bullet.move()
        }
        
        //  发射子弹 右
        if let wingman = _rightWings {
            let bullet = WARBulletNode(type: .player, texture: _bulletsTexture)
            bullet.position = CGPoint(x: position.x + wingman.position.x, y: position.y + wingman.position.y + wingman.size.height/2)
            self.parent!.addChild(bullet)
            bullet.move()
        }
    }
    
    //MARK: Public Methods
    /// 掉血
    ///
    /// - Parameter damage: 伤害值
    func subBlood(damage: Int) {
        currentBlood -= damage
    }

}
