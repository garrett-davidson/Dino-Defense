//
//  SpriteComponent.swift
//  Dino Defense
//
//  Created by Garrett Davidson on 10/29/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {

    let node: SKSpriteNode

    var radius: Float {
        get {
            let size = node.size
            return Float(max(size.width, size.height))/2
        }
    }

    init(texture: SKTexture) {
        node = SKSpriteNode(texture: texture, color: SKColor.white, size: CGSize(width: 20, height: 20))

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
