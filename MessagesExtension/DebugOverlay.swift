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
}
