//
//  WARMenuViewController.swift
//  Warcraft
//
//  Created by kokozu on 2017/3/9.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import UIKit

class WARMenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.black
        
        let startButton = UIButton(type: .custom)
        startButton.bounds = CGRect(x: 0, y: 0, width: 100, height: 50)
        startButton.center = view.center
        startButton.setTitle("开始", for: .normal)
        startButton.setTitleColor(UIColor.white, for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    func startButtonAction() {
        WARResourcesManager.sharedManager.loadTexture()
        
        let gameVC = WARGameViewController()
        navigationController?.pushViewController(gameVC, animated: true)
    }
}
