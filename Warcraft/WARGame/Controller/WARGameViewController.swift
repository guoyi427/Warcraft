//
//  WARGameViewController.swift
//  Warcraft
//
//  Created by kokozu on 2017/3/9.
//  Copyright © 2017年 guoyi. All rights reserved.
//


//  用户区分碰撞的物理类型
let PlayerBitMask: UInt32           = 0x1 << 0  //  玩家飞机
let BulletsBitMask: UInt32          = 0x1 << 1  //  玩家子弹
let EnemyBitMask: UInt32            = 0x1 << 2  //  敌军飞机
let BulletsWithEnemyBitMask: UInt32 = 0x1 << 3  //  敌军子弹

import UIKit

import SpriteKit

class WARGameViewController: UIViewController, SKPhysicsContactDelegate {
    
    var _gameView:SKView! = nil
    let _gameScene = SKScene(size: UIScreen.main.bounds.size)
    fileprivate let _backgroundNode = WARBackgroundNode()
    
    /// 玩家node
    let _playerNode = WARPlayerPlaneNode.sharedInstance()//WARPlayerPlaneNode()
    /// 分数标签
    fileprivate let _scoreLabel = SKLabelNode(text: "0")
    /// 血量
    fileprivate let _bloodLabel = SKLabelNode(text: "0")
    
    /// 保护壳按钮
    fileprivate let _crustButton = UIButton(type: .custom)
    
    /// 缓存触摸开始的点
    var _touchBeganPoint = CGPoint.zero
    /// 缓存玩家最开始的点  每次移动结束都会更新
    var _playerBeganPoint = CGPoint.zero
    
    /// 累计出现的敌机数量
    var _enemyAccumulativeCount:Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _prepareScene()
        _prepareUI()
        //  放置普通敌机
        _putEnemys()
        //  放置队列敌机
        WAREnemysEmitter.sharedInstance.pushEnemy(gameScene: _gameScene)
        //  boss
        _putBossEnemy()
    }
    
    //MARK: Prepare
    
    /// 准备场景
    fileprivate func _prepareScene() {
        view = SKView(frame: UIScreen.main.bounds)
        _gameView = view as! SKView
        
        _gameScene.backgroundColor = SKColor.black
        _gameScene.delegate = self
        //  物理世界
        _gameScene.physicsWorld.contactDelegate = self
        _gameScene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        _gameView.presentScene(_gameScene)
        _gameView.showsFPS = true
        _gameView.showsNodeCount = true
        
        //  滚动背景，滚动在update中执行 background update方法
        _gameScene.addChild(_backgroundNode)
        
        //  玩家飞机
        _gameScene.addChild(_playerNode)
        _playerBeganPoint = _playerNode.position
    }
    
    /// 准备页面
    fileprivate func _prepareUI() {
        //  分数
        _scoreLabel.fontSize = 20
        _scoreLabel.position = CGPoint(x: _gameScene.size.width - 10, y: _gameScene.size.height - 50)
        _scoreLabel.horizontalAlignmentMode = .right
        _gameScene.addChild(_scoreLabel)
        
        //  血量
        _bloodLabel.fontSize = 20
        _bloodLabel.position = CGPoint(x: 10, y: _gameScene.size.height - 50)
        _bloodLabel.horizontalAlignmentMode = .left
        _bloodLabel.text = "血量:\(_playerNode.currentBlood)"
        _gameScene.addChild(_bloodLabel)
        
        /// 保护壳按钮
        _crustButton.backgroundColor = SKColor.blue
        _crustButton.frame = CGRect(x: 0, y: Screen_Height - 80, width: 50, height: 50)
        _crustButton.addTarget(self, action: #selector(_crustButtonAction), for: .touchUpInside)
        _gameView.addSubview(_crustButton)
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
    
    /// 放置boss敌机
    fileprivate func _putBossEnemy() {
        let boss1 = WARBoss1Node(blood: 2000)
        _gameScene.addChild(boss1)
        boss1.show()
    }
    
    /// 创建敌机
    fileprivate func _creatEnemy() {
        let blood = 5 * (_enemyAccumulativeCount/10+1)
        let enemyNode = WARPlaneSpriteNode(blood: blood)
        _gameScene.addChild(enemyNode)
        
        //  向下移动
        let actionMove = SKAction.moveBy(x: 0, y: -_gameScene.size.height, duration: 10)
        let actionDone = SKAction.run {
            enemyNode.removeFromParent()
        }
        enemyNode.run(SKAction.sequence([actionMove, actionDone]))
    }
}

//MARK: Touch Delegate
extension WARGameViewController {
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
            //  保持在屏幕内
            if resultPoint.x > _playerNode.size.width/2 &&
                resultPoint.x < _gameScene.size.width - _playerNode.size.width/2 {
                _playerNode.position = CGPoint(x: resultPoint.x, y: _playerNode.position.y)
            }
            if resultPoint.y > _playerNode.size.height/2 &&
                resultPoint.y < _gameScene.size.height - _playerNode.size.height/2 {
                _playerNode.position = CGPoint(x: _playerNode.position.x, y: resultPoint.y)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //  更新玩家位置
        _playerBeganPoint = _playerNode.position
    }
}

//MARK: 处理碰撞
extension WARGameViewController {
    
    /// 碰撞开始
    ///
    /// - Parameter contact: 碰撞对象
    func didBegin(_ contact: SKPhysicsContact) {
        
        //  玩家子弹 碰撞情况
        if contact.bodyA.categoryBitMask == BulletsBitMask {
            contact.bodyA.node?.removeFromParent()
            self.updateEnemyAfterContact(body: contact.bodyB)
        } else if (contact.bodyB.categoryBitMask == BulletsBitMask) {
            contact.bodyB.node?.removeFromParent()
            self.updateEnemyAfterContact(body: contact.bodyA)
        }
        
        //  玩家飞机 碰撞情况
        if contact.bodyA.categoryBitMask == PlayerBitMask {
            self.updatePlayerAfterContact(body: contact.bodyB)
        } else if contact.bodyB.categoryBitMask == PlayerBitMask {
            self.updatePlayerAfterContact(body: contact.bodyA)
        }
    }
    
    /// 玩家子弹击中敌军
    ///
    /// - Parameter body: 玩家子弹击中的物体
    fileprivate func updateEnemyAfterContact(body: SKPhysicsBody) {
        if body.categoryBitMask == EnemyBitMask {
            if let enemyNode: WARPlaneSpriteNode = body.node as? WARPlaneSpriteNode {
                enemyNode.subBlood()
            } else if let enemyNode = body.node as? WARBoss1Node {
                enemyNode.subBlood()
            }
            _scoreLabel.text = "得分:\(WARScoreManager.sharedManager().currentScore)"
        }
    }
    
    /// 玩家飞机碰撞
    ///
    /// - Parameter body: 击中玩家飞机的物体
    fileprivate func updatePlayerAfterContact(body: SKPhysicsBody) {
        if body.categoryBitMask == BulletsWithEnemyBitMask {
            body.node?.removeFromParent()
            _playerNode.subBlood(damage: 1)
            _bloodLabel.text = "血量:\(_playerNode.currentBlood)"
        }
    }
}

// MARK: - 场景更新
extension WARGameViewController: SKSceneDelegate {
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        _backgroundNode.update()
    }
}

// MARK: - 按钮方法
extension WARGameViewController {
    @objc fileprivate func _crustButtonAction() {
        _playerNode.showCrust()
    }
}
