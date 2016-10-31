//
//  PathFollowingBehavior.swift
//  Dino Defense
//
//  Created by Garrett Davidson on 10/29/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

import SpriteKit
import GameplayKit

class PathFollowingBehavior: GKBehavior {

    init(path: GKPath, forward: Bool) {
        super.init()

        setWeight(1, for: GKGoal(toFollow: path, maxPredictionTime: 1, forward: forward))
    }
}
