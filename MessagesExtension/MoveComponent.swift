//
//  MoveComponent.swift
//  Dino Defense
//
//  Created by Garrett Davidson on 10/29/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

import SpriteKit
import GameplayKit

class MoveComponent: GKAgent2D, GKAgentDelegate {

    let path: GKPath
    let forward: Bool

    init(path: GKPath, maxSpeed: Float, maxAcceleration: Float, radius: Float) {
        self.path = path
        self.forward = maxSpeed > 0
        super.init()

        delegate = self
        self.maxSpeed = fabs(maxSpeed)
        self.maxAcceleration = maxAcceleration
        self.radius = radius
        self.mass = 0.01
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func agentWillUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
            return
        }

        let pos = spriteComponent.node.position
        position = float2(Float(pos.x), Float(pos.y))
    }

    func agentDidUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
            return
        }
        spriteComponent.node.position = position.toCGPoint()
        print("At position \(position)")
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        behavior = PathFollowingBehavior(path: path, forward: forward)
    }
}

extension vector_float2 {
    func toCGPoint() -> CGPoint {
        return CGPoint(x: CGFloat(self[0]), y: CGFloat(self[1]))
    }
}
