//
//  DebugOverlay.swift
//  Dino Defense
//
//  Created by Garrett Davidson on 11/7/16.
//  Copyright © 2016 Garrett Davidson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class DebugOverlay {
    let scene: SKScene

    init(scene: SKScene) {
        self.scene = scene
    }

    func draw(_ path: GKPath) {
        var points = [float2]()
        for i in 0..<path.numPoints {
            points.append(path.float2(at: i))
        }
        let cgPoints = points.map(CGPoint.init)
        let node = SKShapeNode(points: UnsafeMutablePointer(mutating: cgPoints), count: cgPoints.count)

        node.strokeColor = .black
        node.lineWidth = CGFloat(path.radius)
        node.alpha = 0.5

        scene.addChild(node)
    }

    func draw(_ obstacleGraph: GKObstacleGraph<GKGraphNode2D>) {

        let bufferRadius = CGFloat(obstacleGraph.bufferRadius)
        obstacleGraph.obstacles.forEach { (obstacle) in
            draw(obstacle, bufferRadius: bufferRadius)
        }

        obstacleGraph.nodes?.forEach({ (node) in
            if let node = node as? GKGraphNode2D {
                draw(node)
            }
        })
    }

    func draw(_ meshGraph: GKMeshGraph<GKGraphNode2D>) {
        for i in 0..<meshGraph.triangleCount {
            draw(meshGraph.triangle(at: i))
        }

        let bufferRadius = CGFloat(meshGraph.bufferRadius)
        meshGraph.obstacles.forEach { (obstacle) in
            draw(obstacle, bufferRadius: bufferRadius)
        }

    }

    func draw(_ triangle: GKTriangle) {
        let points = [CGPoint(triangle.points.0), CGPoint(triangle.points.1), CGPoint(triangle.points.2), CGPoint(triangle.points.0)]
        let node = SKShapeNode(points: UnsafeMutablePointer(mutating: points), count: 4)

        node.fillColor = .green
        node.strokeColor = .green
        node.alpha = 0.5

        scene.addChild(node)
    }

    func draw(_ obstacle: GKPolygonObstacle, bufferRadius: CGFloat = 0) {
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

        scene.addChild(node)
    }

    func draw(_ graphNode: GKGraphNode2D, radius: CGFloat = 2, color: UIColor = .blue) {
        let shape = SKShapeNode(circleOfRadius: radius)
        shape.position = graphNode.position.toCGPoint()
        shape.strokeColor = color
        shape.fillColor = color
        shape.alpha = 0.5
        scene.addChild(shape)
    }

    var placabilityMatrixLayers: [CAShapeLayer]?
    func drawPlacabilityMatrix(dx: CGFloat = 18.75, dy: CGFloat = 18.75, radius: CGFloat = 3, color: UIColor = .blue) {
        guard let scene = scene as? GameScene else {
            print("Cannot draw matrix on non-GameScene")
            return
        }

        let width = min(scene.view!.bounds.size.width, scene.view!.bounds.size.height)

        placabilityMatrixLayers = []
        let size = CGSize(width: radius * 2, height: radius * 2)
        let currentPosition = scene.view!.convert(CGPoint(x: -scene.mapNode.mapSize.width/2, y: scene.mapNode.mapSize.height/2), from: scene)

        print(width)
        print(size)
        print(currentPosition)
        let tileWidth = width / CGFloat(scene.gridWidth)
        let tileHeight = width / CGFloat(scene.gridHeight)
        for x in stride(from: currentPosition.x - radius + dx, through: width + currentPosition.x + radius, by: dx) {
            for y in stride(from: currentPosition.y - radius + dy, through: width + currentPosition.y + radius, by: dy) {
                let node = CAShapeLayer()

                let center = CGPoint(x: x, y: y)
//                let convertedCenter = scene.convert(center, to: scene.mapNode)
//                let convertedCenter2 = scene.positionFromPoint(point: center)
                let convertedCenter3 = CGPoint(x: center.x + radius - currentPosition.x, y: center.y + radius - currentPosition.y)
                let xCoordinate = Int(convertedCenter3.x / tileWidth)
                let yCoordinate = Int(scene.gridHeight) - Int(ceil(convertedCenter3.y / tileHeight))
                print(center)
                print(convertedCenter3)
                print(xCoordinate, yCoordinate)
                let a = scene.mapNode.tileGroup(atColumn: xCoordinate, row: yCoordinate) == nil
                print("Road exists: ", a)
//                if scene.canPlaceTowerAt(point: convertedCenter3) {
                if a {
                    node.path = UIBezierPath(ovalIn: CGRect(origin: center, size: size)).cgPath
                    node.fillColor = color.cgColor

                    placabilityMatrixLayers!.append(node)
                    scene.view?.layer.addSublayer(node)
                }
            }
        }
    }

    func clearPlacabilityMatrix() {
        guard placabilityMatrixLayers != nil else {
            return
        }

        placabilityMatrixLayers?.forEach({ (layer) in
            layer.removeFromSuperlayer()
        })

        placabilityMatrixLayers = nil
    }
}
