//
//  WARScoreManager.swift
//  Warcraft
//
//  Created by 郭毅 on 2017/3/9.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import Foundation

class WARScoreManager {
    /// 单例
    static let _instance:WARScoreManager = WARScoreManager()
    /// 分数
    public var currentScore = 0
    
    class func sharedManager() -> WARScoreManager {
        return _instance
    }
    
    func addScore(score: Int) {
        currentScore = currentScore + score
    }
}
