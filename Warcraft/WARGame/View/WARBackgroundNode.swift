//
//  WARBackgroundNode.swift
//  Warcraft
//
//  Created by kokozu on 2017/6/22.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

class WARBackgroundNode: SKNode {
    
    let _sprite1 = SKSpriteNode.init(color: UIColor.orange, size: Screen_Size)
    let _sprite2 = SKSpriteNode.init(color: UIColor.brown, size: Screen_Size)
    
    var _upSprite: SKSpriteNode
    var _downSprite: SKSpriteNode
    
    let _speed: CGFloat = 2.0
    
    override init() {
        _upSprite = _sprite1
        _downSprite = _sprite2
        super.init()
        _sprite1.position = CGPoint(x: Screen_Width/2.0, y: Screen_Height*1.5)
        _sprite2.position = CGPoint(x: Screen_Width/2.0, y: Screen_Height/2.0)
        addChild(_sprite1)
        addChild(_sprite2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Public - Methods
extension WARBackgroundNode {
    func update() {
        //  向下移动
        _upSprite.position = CGPoint(x: _upSprite.position.x, y: _upSprite.position.y - _speed)
        _downSprite.position = CGPoint(x: _downSprite.position.x, y: _downSprite.position.y - _speed)
        
        //  判断位置 是否需要 更换位置
        if _upSprite.position.y <= Screen_Height/2.0 {
            //  upSprite, downSprite 交换
            let tempSprite = _upSprite
            _upSprite = _downSprite
            _downSprite = tempSprite
            //  将 up 挪到 上面去
            _upSprite.position = CGPoint(x: _upSprite.position.x, y: Screen_Height*1.5)
        }
    }
}
