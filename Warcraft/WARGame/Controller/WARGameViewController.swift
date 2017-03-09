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
    let _enemysTexture = SKTexture(image: #imageLiteral(resourceName: "plane3"))
    
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
        
        _playerNode.position = CGPoint(x: _gameScene.size.width/2, y: _playerSize.height/2)
        _playerBeganPoint = _playerNode.position
        _playerNode.size = _playerSize
        _gameScene.addChild(_playerNode)
    }
    
    /// 发射子弹
    fileprivate func _shootBullets() {
        let creatBullet = SKAction.run {
            self._creatBullet()
        }
        let waiteShoot = SKAction.wait(forDuration: 0.25)
        _gameScene.run(SKAction.repeatForever(SKAction.sequence([creatBullet, waiteShoot])))

    }
    
    /// 生成子弹
    fileprivate func _creatBullet() {
        let bulletsNode = SKSpriteNode(texture: _bulletsTexture)
        bulletsNode.position = CGPoint(x: _playerNode.position.x, y: _playerNode.position.y + _playerNode.size.height/2)
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
    
    /// 放置敌机
    fileprivate func _putEnemys() {
        let creatEnemy = SKAction.run {
            self._creatEnemy()
        }
        let waitePut = SKAction.wait(forDuration: 3)
        _gameScene.run(SKAction.repeatForever(SKAction.sequence([creatEnemy, waitePut])))
    }
    
    /// 创建敌机
    fileprivate func _creatEnemy() {
        
        let enemyNode = WARPlaneSpriteNode(blood: 5, texture: _enemysTexture)//SKSpriteNode(texture: _enemysTexture)
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
        }
    }
    
}
