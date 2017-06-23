//
//  WARResourcesManager.swift
//  Warcraft
//
//  Created by kokozu on 2017/6/23.
//  Copyright © 2017年 guoyi. All rights reserved.
//

import SpriteKit

let key_jiguang = "Player_daojujiguang"
let key_bullets = "bullets"
let key_bulletsPurple = "bulletsPurple"
let key_plane1 = "plane1"
let key_plane2 = "plane2"
let key_plane3 = "plane3"
let key_baohuke1 = "wsparticle_akl_jiaxue1"

//  plist name
let name_jiguangPlist = "Player_daojujiguang"
let name_baohuke1Plist = "wsparticle_akl_jiaxue1"

class WARResourcesManager: NSObject {
    static let sharedManager = WARResourcesManager()
    
    fileprivate var _resourcesDic:[String: SKTexture] = [:]
    fileprivate var _plistDic:[String:[String: AnyObject]] = [:]
    
    override init() {
        super.init()
        
    }
    
    func loadTexture() {
        _resourcesDic.updateValue(SKTexture(image: #imageLiteral(resourceName: "Player_daojujiguang")), forKey: key_jiguang)
        _resourcesDic.updateValue(SKTexture(image: #imageLiteral(resourceName: "bullets")), forKey: key_bullets)
        _resourcesDic.updateValue(SKTexture(image: #imageLiteral(resourceName: "Bullets_Purple")), forKey: key_bulletsPurple)
        _resourcesDic.updateValue(SKTexture(image: #imageLiteral(resourceName: "plan1")), forKey: key_plane1)
        _resourcesDic.updateValue(SKTexture(image: #imageLiteral(resourceName: "plane2")), forKey: key_plane2)
        _resourcesDic.updateValue(SKTexture(image: #imageLiteral(resourceName: "plane3")), forKey: key_plane3)
        _resourcesDic.updateValue(SKTexture(image: #imageLiteral(resourceName: "wsparticle_akl_jiaxue1")), forKey: key_baohuke1)
        
        _plistDic.updateValue(_fetchPlist(fileName: name_jiguangPlist), forKey: name_jiguangPlist)
        _plistDic.updateValue(_fetchPlist(fileName: name_baohuke1Plist), forKey: name_baohuke1Plist)
        
        
    }
    
    func fetchTexture(name: String) -> SKTexture {
        return _resourcesDic[name]!
    }
    
    func fetchTextureList(name: String) -> [SKTexture] {
        let plistData = _fetchPlist(fileName: name)
        
        let framesDic:[String: AnyObject] = plistData["frames"] as! Dictionary
        
        /// 所有frame对应的key
        var imageKeys:[String] = []
        for keys in framesDic.keys {
            imageKeys.append(keys)
        }
        
        imageKeys.sort()
        
        var textureFrameList:[AnyObject] = []
        
        //  依次取出frame
        for tempKey in imageKeys {
            if let textureDic:[String: AnyObject] = framesDic[tempKey] as! [String : AnyObject]? {
                if let textureFrame = textureDic["frame"] {
                    textureFrameList.append(textureFrame)
                }
            }
        }
        
        //  总纹理，所有纹理结合到一起的那个
        let allTexture = fetchTexture(name: name)
        
        var textureList:[SKTexture] = []
        let textureSize = allTexture.size()
        //  遍历frame，依次从总纹理中切割出单个纹理
        for textureFrameValue in textureFrameList {
            if let frameString: String = textureFrameValue as? String {
                var textureRect = CGRectFromString(frameString)
//                textureRect.origin.x = textureRect.origin.x/2   //  因为分辨率愿意，单位像素 = pixel／2
//                textureRect.origin.y = textureRect.origin.y/2
//                textureRect.size.width = textureRect.size.width/2
//                textureRect.size.height = textureRect.size.height/2
//                let newFrame = CGRect(x: textureRect.origin.x/textureSize.width, y: textureRect.origin.y/textureSize.height, width: textureRect.size.width/textureSize.width, height: textureRect.size.height/textureSize.height)
                
                let oneTexture = SKTexture(rect: textureRect, in: allTexture)
                textureList.append(oneTexture)
            }
        }
        
        return textureList
    }
}

// MARK: - Private - Methods
extension WARResourcesManager {
    fileprivate func _fetchPlist(fileName: String) -> [String: AnyObject] {
        var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        var plistData: [String: AnyObject] = [:] //Our data
        let plistPath: String? = Bundle.main.path(forResource: fileName, ofType: "plist")! //the path of the data
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        do {//convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListForamt) as! [String:AnyObject]
            
        } catch {
            print("Error reading plist: \(error), format: \(propertyListForamt)")
        }
        return plistData
    }
}
