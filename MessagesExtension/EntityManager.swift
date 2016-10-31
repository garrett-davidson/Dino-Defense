//
//  EntityManager.swift
//  Dino Defense
//
//  Created by Garrett Davidson on 10/29/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

import SpriteKit
import GameplayKit

class EntityManager {

    var entities = Set<GKEntity>()
    let scene: SKScene
    var toRemove = Set<GKEntity>()

    init(scene: SKScene) {
        self.scene = scene
    }

    func add(entity: GKEntity) {
        entities.insert(entity)

        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            scene.addChild(spriteNode)
        }

        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
    }

    func remove(entity: GKEntity) {
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            spriteNode.removeFromParent()
        }

        entities.remove(entity)
        toRemove.insert(entity)
    }

    lazy var componentSystems: [GKComponentSystem] = {
        let minionSystem = GKComponentSystem(componentClass: Minion.self)
        let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
        return [minionSystem, moveSystem]
    }()

    func update(deltaTime: CFTimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }

        for curRemove in toRemove {
            for componentSystem in componentSystems {
                componentSystem.removeComponent(foundIn: curRemove)
            }
        }
        toRemove.removeAll()
    }

    func resetCantaloupe() {
        entities.first?.component(ofType: MoveComponent.self)?.position = float2(-160, 160)
    }
}
