//
//  MapScene.swift
//  Dino Defense
//
//  Created by Garrett Davidson on 10/29/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {

    let debugging = true

    var mapNode: SKTileMapNode!
    var entityManager: EntityManager!
    var startNode: GKGraphNode2D!
    var endNode: GKGraphNode2D!

    var debugOverlay: DebugOverlay!

    let gridWidth: Int32 = 10
    let gridHeight: Int32 = 10

    override init() {
        super.init()

        self.debugOverlay = debugging ? DebugOverlay(scene: self) : nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.debugOverlay = debugging ? DebugOverlay(scene: self) : nil
    }

    func loadMap() {
        guard let mapNode = childNode(withName: "Map") as? SKTileMapNode else {
            print("Unable to load map")
            return
        }
        self.mapNode = mapNode
    }

    override func didMove(to view: SKView) {
        setup()
    }

    var path: GKPath!

    func setup() {
        entityManager = EntityManager(scene: self)

        loadMap()
        let graph = loadObstacles()
        let pathNodes = graph.findPath(from: startNode, to: endNode)

        if pathNodes.count < 2 {
            print("Couldn't find path")
            return
        }

        path = GKPath(graphNodes: pathNodes, radius: 5)

        if debugging {
            debugOverlay.draw(path)
        }
    }

    func placeTestCantaloupe() {
        if mapNode == nil {
            setup()
        }
        guard path != nil else {
            return
        }
        let testCantaloupe = Minion(imageName: "Cantaloupe", path: path, entityManager: entityManager)
        if let spriteComponent = testCantaloupe.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = positionFromPoint(point: CGPoint(x: spriteComponent.node.size.width/2, y: spriteComponent.node.size.height/2))
        }
        entityManager.add(entity: testCantaloupe)
    }

    func loadObstacles() -> GKMeshGraph<GKGraphNode2D> {
        func pointsForTile(atColumn column: Int, row: Int) -> [float2] {
            var points = [float2]()

            let tileSize = mapNode.tileSize
            let columnF = Float(column)
            let rowF = Float(row)
            let width = Float(tileSize.width)
            let height = Float(tileSize.height)

            let mapWidth = Float(mapNode.tileSize.width) * Float(gridWidth) / 2
            let mapHeight = Float(mapNode.tileSize.height) * Float(gridHeight) / 2

            points.append(float2(columnF * width - mapWidth, rowF * height - mapHeight)) //bottom left
            points.append(float2((columnF + 1) * width - mapWidth, rowF * height - mapHeight)) //bottom right
            points.append(float2((columnF + 1) * width - mapWidth, (rowF + 1) * height - mapHeight)) //top right
            points.append(float2(columnF * width - mapWidth, (rowF + 1) * height - mapWidth)) //top left

            return points
        }

        var obstacles = [GKPolygonObstacle]()
        for i in 0..<Int(gridWidth) {
            for j in 0..<Int(gridHeight) {
                if mapNode.tileGroup(atColumn: i, row: j) == nil {
                    obstacles.append(GKPolygonObstacle(points: pointsForTile(atColumn: i, row: j)))
                }
            }
        }

        // DO NOT REMOVE
        // For some reason, we hit an assertion failure in triangulate() when there is an obstacle in the bottom left corner
        obstacles.removeFirst()

        let graph = GKMeshGraph(bufferRadius: 0, minCoordinate: positionFromPoint(point: CGPoint(x: 0, y: mapNode.mapSize.height)).toFloat2(), maxCoordinate: positionFromPoint(point: CGPoint(x: mapNode.mapSize.width, y: 0)).toFloat2())
        startNode = GKGraphNode2D(point: positionFromPoint(point: CGPoint(x: 16, y: 16)).toFloat2())
        endNode = GKGraphNode2D(point: positionFromPoint(point: CGPoint(x: mapNode.mapSize.width - 16, y: mapNode.mapSize.height - 16)).toFloat2())
        graph.addObstacles(obstacles)
        print("Graph has \(graph.obstacles.count) obstacles")

        graph.triangulationMode = [.centers, .edgeMidpoints]
        graph.triangulate()
        print("Graph has \(graph.obstacles.count) obstacles")

        graph.connectUsingObstacles(node: startNode)
        graph.connectUsingObstacles(node: endNode)

        if debugging {
            debugOverlay.draw(graph)
        }

        return graph
    }

    func positionFromPoint(point: CGPoint) -> CGPoint {
        let width = mapNode.tileSize.width * CGFloat(gridWidth) / 2
        let height = mapNode.tileSize.height * CGFloat(gridHeight) / 2

        let returnPoint = CGPoint(x: point.x - width, y: height - point.y)
        print("Converted \(point) to \(returnPoint)")
        return returnPoint
    }

    var lastTime = 0.0
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        entityManager.update(deltaTime: currentTime - lastTime)
        lastTime = currentTime
    }
}

extension CGPoint {
    func toFloat2() -> vector_float2 {
        return float2(Float(self.x), Float(self.y))
    }

    init(_ vector: float2) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }

    init(_ vector: vector_float3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
}
