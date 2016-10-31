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

    init(texture: SKTexture) {
        node = SKSpriteNode(texture: texture, color: SKColor.white, size: texture.size())

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
