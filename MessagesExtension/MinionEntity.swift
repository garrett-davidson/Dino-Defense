//
//  MinionEntity.swift
//  Dino Defense
//
//  Created by Garrett Davidson on 10/29/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

import SpriteKit
import GameplayKit

class Minion: GKEntity {

    init(imageName: String, path: GKPath, entityManager: EntityManager) {
        super.init()

        let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: imageName))
        addComponent(spriteComponent)
        addComponent(MoveComponent(path: path, maxSpeed: 50, maxAcceleration: 50, radius: spriteComponent.radius))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
