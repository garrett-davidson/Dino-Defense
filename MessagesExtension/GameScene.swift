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

    var mapNode: SKTileMapNode!
    var entityManager: EntityManager!
    var startNode: GKGraphNode2D!
    var endNode: GKGraphNode2D!

    let gridWidth: Int32 = 10
    let gridHeight: Int32 = 10

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

        path = GKPath(graphNodes: pathNodes, radius: 1)

        draw(path: path)
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
                    let points = pointsForTile(atColumn: i, row: j)
                    obstacles.append(GKPolygonObstacle(__points: UnsafeMutablePointer(mutating: points), count: points.count))
//                    obstacles.append(GKPolygonObstacle(points: pointsForTile(atColumn: i, row: j)))
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

        graph.triangulationMode = .vertices
        graph.triangulate()
        print("Graph has \(graph.obstacles.count) obstacles")

        graph.connectUsingObstacles(node: startNode)
        graph.connectUsingObstacles(node: endNode)

        draw(meshGraph: graph)

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

    func draw(path: GKPath) {
        var points = [float2]()
        for i in 0..<path.numPoints {
            points.append(path.float2(at: i))
        }
        let cgPoints = points.map(CGPoint.init)
        let node = SKShapeNode(points: UnsafeMutablePointer(mutating: cgPoints), count: cgPoints.count)

        node.strokeColor = .black
        node.lineWidth = CGFloat(path.radius)
        node.alpha = 0.5

        self.addChild(node)
    }

    func draw(obstacleGraph: GKObstacleGraph<GKGraphNode2D>) {

        let bufferRadius = CGFloat(obstacleGraph.bufferRadius)
        obstacleGraph.obstacles.forEach { (obstacle) in
            draw(obstacle: obstacle, bufferRadius: bufferRadius)
        }

        obstacleGraph.nodes?.forEach({ (node) in
            if let node = node as? GKGraphNode2D {
                draw(graphNode: node)
            }
        })
    }

    func draw(meshGraph: GKMeshGraph<GKGraphNode2D>) {
        for i in 0..<meshGraph.triangleCount {
            draw(triangle: meshGraph.triangle(at: i))
        }

        let bufferRadius = CGFloat(meshGraph.bufferRadius)
        meshGraph.obstacles.forEach { (obstacle) in
            draw(obstacle: obstacle, bufferRadius: bufferRadius)
        }

    }

    func draw(triangle: GKTriangle) {
        let points = [CGPoint(triangle.points.0), CGPoint(triangle.points.1), CGPoint(triangle.points.2), CGPoint(triangle.points.0)]
        let node = SKShapeNode(points: UnsafeMutablePointer(mutating: points), count: 4)

        node.fillColor = .green
        node.strokeColor = .green
        node.alpha = 0.5

        self.addChild(node)
    }

    func draw(obstacle: GKPolygonObstacle, bufferRadius: CGFloat = 0) {
        let vertexCount = obstacle.vertexCount
        guard vertexCount > 0 else {
            return
        }

        var points = [float2]()
        for i in 0..<vertexCount {
            points.append(obstacle.vertex(at: i))
        }
        points.append(points.first!) // Adds a line to close the object

        let cgPoints = points.map(CGPoint.init)
        let node = SKShapeNode(points: UnsafeMutablePointer(mutating: cgPoints), count: cgPoints.count)

        node.strokeColor = .red
        node.fillColor = .red
        node.alpha = 0.5
        node.lineWidth = bufferRadius

        self.addChild(node)
    }

    func draw(graphNode: GKGraphNode2D, radius: CGFloat = 2, color: UIColor = .blue) {
        let shape = SKShapeNode(circleOfRadius: radius)
        shape.position = graphNode.position.toCGPoint()
        shape.strokeColor = color
        shape.fillColor = color
        shape.alpha = 0.5
        self.addChild(shape)
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
