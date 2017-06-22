//
//  WARPlayerPlaneNode.swift
//  Warcraft
//
//  Created by 郭毅 on 2017/3/11.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

class WARPlayerPlaneNode: SKSpriteNode {
    
    static let _instance = WARPlayerPlaneNode()
    
    /// 屏幕size
    fileprivate let ScreenSize = UIScreen.main.bounds.size
    
    /// 子弹纹理，一次加载多次使用
    let _bulletsTexture = SKTexture(image: #imageLiteral(resourceName: "bullets"))
    /// 极光纹理
    let _jiguangTexture = SKTexture(image: #imageLiteral(resourceName: "Player_daojujiguang"))
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
    
    /// 单例
    ///
    /// - Returns: 实例对象
    class func sharedInstance() -> WARPlayerPlaneNode {
        return _instance
    }
    
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
        
//        let showJiguangAction = SKAction.run {
//            self._creatJiguangBullets()
//        }
//        run(SKAction.sequence([SKAction.wait(forDuration: 0.2), showJiguangAction]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Private Methods
    
    fileprivate func _creatJiguangBullets() {
        var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        var plistData: [String: AnyObject] = [:] //Our data
        let plistPath: String? = Bundle.main.path(forResource: "Player_daojujiguang", ofType: "plist")! //the path of the data
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        do {//convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListForamt) as! [String:AnyObject]
            
        } catch {
            print("Error reading plist: \(error), format: \(propertyListForamt)")
        }
        
        let framesDic:[String: AnyObject] = plistData["frames"] as! Dictionary
        var imageKeys:[String] = []
        for keys in framesDic.keys {
            imageKeys.append(keys)
        }
        
        imageKeys.sort()
        
        print("image keys \(imageKeys)")
        
        var textureFrameList:[AnyObject] = []
    
        for tempKey in imageKeys {
            /*{
             frame = "{{333,0},{110,506}}";
             offset = "{1,-3}";
             rotated = 0;
             sourceColorRect = "{{10,6},{110,506}}";
             */
            if let textureDic:[String: AnyObject] = framesDic[tempKey] as! [String : AnyObject]? {
                if let textureFrame = textureDic["frame"] {
                    textureFrameList.append(textureFrame)
                }
            }
        }
        
        print("frames list = \(textureFrameList)")
        
        var textureList:[SKTexture] = []
        let textureSize = _jiguangTexture.size()
        for textureFrameValue in textureFrameList {
            if let frameString: String = textureFrameValue as? String {
                var textureRect = CGRectFromString(frameString)
                textureRect.origin.x = textureRect.origin.x/2
                textureRect.origin.y = textureRect.origin.y/2
                textureRect.size.width = textureRect.size.width/2
                textureRect.size.height = textureRect.size.height/2
                let newFrame = CGRect(x: textureRect.origin.x/textureSize.width, y: textureRect.origin.y/textureSize.height, width: textureRect.size.width/textureSize.width, height: textureRect.size.height/textureSize.height)
                let jiguangTexture = SKTexture(rect: newFrame, in: _jiguangTexture)
                textureList.append(jiguangTexture)
            }
        }
        
        let bullet = SKSpriteNode(texture: textureList.first)
        bullet.position = CGPoint(x: 0, y: self.size.height/2 + textureSize.height/2)
        addChild(bullet)
        
        let action = SKAction.animate(with: textureList, timePerFrame: 0.1)
        bullet.run(SKAction.repeatForever(action))
    }
    
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
//            let bulletsNode = WARBulletNode(type: .player, texture: _bulletsTexture)
            let bulletsNode = SKSpriteNode(texture: _bulletsTexture)
            bulletsNode.preparePhysicsBody(type: .player)
            //  计算 position
           _calculateBulletPosition(bulletsNode: bulletsNode, bulletsCount: bulletsCount, index: index)
            self.parent!.addChild(bulletsNode)
            bulletsNode.move(type: .player)
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
//            let bullet = WARBulletNode(type: .player, texture: _bulletsTexture)
            let bullet = SKSpriteNode(texture: _bulletsTexture)
            bullet.preparePhysicsBody(type: .player)
            bullet.position = CGPoint(x: position.x + wingman.position.x, y: position.y + wingman.position.y + wingman.size.height/2)
            self.parent!.addChild(bullet)
            bullet.move(type: .player)
        }
        
        //  发射子弹 右
        if let wingman = _rightWings {
//            let bullet = WARBulletNode(type: .player, texture: _bulletsTexture)
            let bullet = SKSpriteNode(texture: _bulletsTexture)
            bullet.preparePhysicsBody(type: .player)
            bullet.position = CGPoint(x: position.x + wingman.position.x, y: position.y + wingman.position.y + wingman.size.height/2)
            self.parent!.addChild(bullet)
            bullet.move(type: .player)
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
