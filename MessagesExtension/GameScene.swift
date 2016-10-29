//
//  GameScene.swift
//  Dino Defense
//
//  Created by Garrett Davidson on 10/29/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var mapNode: SKTileMapNode!

    func loadMap() {
        guard let mapNode = childNode(withName: "Map") as? SKTileMapNode else {
            print("Unable to load map")
            return
        }
        self.mapNode = mapNode
    }

    override func didMove(to view: SKView) {
        loadMap()
    }
}
