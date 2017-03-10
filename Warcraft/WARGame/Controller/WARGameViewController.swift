//
//  WARGameViewController.swift
//  Warcraft
//
//  Created by kokozu on 2017/3/9.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import UIKit

import SpriteKit

class WARGameViewController: UIViewController, SKPhysicsContactDelegate {
    
    var _gameView:SKView! = nil
    let _gameScene = SKScene(size: UIScreen.main.bounds.size)
    /// 玩家size
    let _playerSize = CGSize(width: 40, height: 40)
    /// 玩家node
    let _playerNode = SKSpriteNode(imageNamed: "plane2")
    /// 子弹纹理，一次加载多次使用
    let _bulletsTexture = SKTexture(imageNamed: "bulltes")
    /// 敌机纹理
    let _enemysTexture = SKTexture(image: #imageLiteral(resourceName: "plane3"))
    /// 分数标签
    let _scoreLabel = SKLabelNode(text: "0")
    
    /// 缓存触摸开始的点
    var _touchBeganPoint = CGPoint.zero
    /// 缓存玩家最开始的点  每次移动结束都会更新
    var _playerBeganPoint = CGPoint.zero
    
    //  用户区分碰撞的物理类型
    let PlayerBitMask: UInt32   = 0x1 << 0
    let BulletsBitMask: UInt32  = 0x1 << 1
    let EnemyBitMask: UInt32    = 0x1 << 2
    
    //  名称
    let EnemyNodeName = "EnemyNode"
    let BulletNodeName = "BulletNode"
    
    /// 每分钟发射多少发炮弹
    var BulletsShootPM: Double = 300
    /// 累计出现的敌机数量
    var _enemyAccumulativeCount:Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _prepareScene()
        _shootBullets()
        _putEnemys()
    }
    
    //MARK: Prepare
    
    /// 准备场景
    fileprivate func _prepareScene() {
        view = SKView(frame: UIScreen.main.bounds)
        _gameView = view as! SKView
        
        _gameScene.backgroundColor = SKColor.black
        
        //  物理世界
        _gameScene.physicsWorld.contactDelegate = self
        _gameScene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        _gameView.presentScene(_gameScene)
        _gameView.showsFPS = true
        _gameView.showsNodeCount = true
        
        //  玩家飞机
        _playerNode.position = CGPoint(x: _gameScene.size.width/2, y: _playerSize.height/2)
        _playerBeganPoint = _playerNode.position
        _playerNode.size = _playerSize
        _gameScene.addChild(_playerNode)
        
        //  分数
        _scoreLabel.fontSize = 20
        _scoreLabel.position = CGPoint(x: 100, y: 40)
        _scoreLabel.horizontalAlignmentMode = .left
        _gameScene.addChild(_scoreLabel)
    }
    
    /// 发射子弹
    fileprivate func _shootBullets() {
        let creatBullet = SKAction.run {
            //  每1000分 加一个子弹发射器
            let count = WARScoreManager.sharedManager().currentScore/1000+1
            self._creatBullet(count: count)
        }
        
        let waiteShoot = SKAction.wait(forDuration: 60/BulletsShootPM)
        _gameScene.run(SKAction.repeatForever(SKAction.sequence([creatBullet, waiteShoot])))

    }
    
    /// 生成子弹
    fileprivate func _creatBullet(count: Int) {
        var bulletsCount = count
        
        if count>5 {
            bulletsCount = 5
        }
        let padding:CGFloat = 2.5*CGFloat(bulletsCount-1)
        
        for index in 1...bulletsCount {
            let bulletsNode = SKSpriteNode(texture: _bulletsTexture)
            bulletsNode.position = CGPoint(x: _playerNode.position.x - padding + CGFloat(index-1) * 5,
                                           y: _playerNode.position.y + _playerNode.size.height/2)
            bulletsNode.name = BulletNodeName
            
            //  物理属性
            bulletsNode.physicsBody = SKPhysicsBody(rectangleOf: bulletsNode.size)
            bulletsNode.physicsBody?.categoryBitMask = BulletsBitMask
            bulletsNode.physicsBody?.collisionBitMask = EnemyBitMask
            bulletsNode.physicsBody?.contactTestBitMask = EnemyBitMask
            
            _gameScene.addChild(bulletsNode)
            
            //  向上移动
            let actionMove = SKAction.moveBy(x: 0, y: _gameScene.size.height, duration: 1)
            let actionDone = SKAction.run {
                bulletsNode.removeFromParent()
            }
            bulletsNode.run(SKAction.sequence([actionMove, actionDone]))
        }
    }
    
    /// 放置敌机
    fileprivate func _putEnemys() {
        let creatEnemy = SKAction.run {
            self._enemyAccumulativeCount += 1
            self._creatEnemy()
        }
        let waitePut = SKAction.wait(forDuration: 2)
        _gameScene.run(SKAction.repeatForever(SKAction.sequence([creatEnemy, waitePut])))
    }
    
    /// 创建敌机
    fileprivate func _creatEnemy() {
        let blood = 5 * (_enemyAccumulativeCount/10+1)
        let enemyNode = WARPlaneSpriteNode(blood: blood, texture: _enemysTexture)//SKSpriteNode(texture: _enemysTexture)
        //  随机位置
        let x_position = arc4random()%UInt32(_gameScene.size.width-enemyNode.size.width) + UInt32(enemyNode.size.width/2)
        enemyNode.position = CGPoint(x: CGFloat(x_position), y: _gameScene.size.height-enemyNode.size.height)
        enemyNode.zRotation = CGFloat(M_PI)
        enemyNode.name = EnemyNodeName
        
        //  物理属性
        enemyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemyNode.size.width, height: enemyNode.size.height*0.3))//扁长不露馅，用纹理获取不规则图片过于消耗性能 所以直接用固定扁长size
        enemyNode.physicsBody?.categoryBitMask = EnemyBitMask
        enemyNode.physicsBody?.collisionBitMask = BulletsBitMask
        enemyNode.physicsBody?.contactTestBitMask = BulletsBitMask
        
        _gameScene.addChild(enemyNode)
        
        //  向下移动
        let actionMove = SKAction.moveBy(x: 0, y: -_gameScene.size.height, duration: 10)
        let actionDone = SKAction.run {
            enemyNode.removeFromParent()
        }
        enemyNode.run(SKAction.sequence([actionMove, actionDone]))
    }
    
    //MARK: Touch Delegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touche = touches.first {
            //  保存 初始点击位置
            _touchBeganPoint = touche.location(in: _gameScene)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touche = touches.first {
            // 获取相对点击位置
            let point = touche.location(in: _gameScene)
            let resultPoint = CGPoint(x: point.x - _touchBeganPoint.x + _playerBeganPoint.x,
                                      y: point.y - _touchBeganPoint.y + _playerBeganPoint.y)
            _playerNode.position = resultPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //  更新玩家位置
        _playerBeganPoint = _playerNode.position
    }
    
    //MARK: Contact Delegate
    
    /// 碰撞开始
    ///
    /// - Parameter contact: 碰撞对象
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == BulletsBitMask {
            contact.bodyA.node?.removeFromParent()
            self.updateEnemyAfterContact(body: contact.bodyB)
        } else if (contact.bodyB.categoryBitMask == BulletsBitMask) {
            contact.bodyB.node?.removeFromParent()
            self.updateEnemyAfterContact(body: contact.bodyA)
        }
    }
    
    func updateEnemyAfterContact(body: SKPhysicsBody) {
        if body.categoryBitMask == EnemyBitMask, let enemyNode: WARPlaneSpriteNode = body.node as? WARPlaneSpriteNode {
            enemyNode.subBlood()
            _scoreLabel.text = "\(WARScoreManager.sharedManager().currentScore)"
        }
    }
    
}
