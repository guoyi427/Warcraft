//
//  WARPlaneSpriteNode.swift
//  Warcraft
//
//  Created by kokozu on 2017/3/9.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

class WARPlaneSpriteNode: SKSpriteNode {
    
    /// 当前血量
    var currentBlood: Int = 1
    
    
    init(blood: Int, texture: SKTexture) {
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        currentBlood = blood
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func subBlood() {
        currentBlood = currentBlood - 1
        if currentBlood <= 0 {
            removeFromParent()
        }
    }
    
}
