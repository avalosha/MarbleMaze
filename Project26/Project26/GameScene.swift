//
//  GameScene.swift
//  Project26
//
//  Created by Álvaro Ávalos Hernández on 20/10/20.
//

import CoreMotion
import SpriteKit

class GameScene: SKScene {
    
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isGameOver = false
    let spriteNodes = SpriteNodes()
    var gameOverLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        let background = spriteNodes.createBackground()
        addChild(background)
        
        scoreLabel = spriteNodes.addScoreLabel()
        addChild(scoreLabel)
        
        loadLevel()
        
        player = spriteNodes.createPlayer()
        addChild(player)
        
        physicsWorld.contactDelegate = self
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }

        let lines = levelString.components(separatedBy: "\n")
        
        var node = SKSpriteNode()

        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                if letter == "x" {
                    // load wall
                    node = spriteNodes.createWall(in: position)
                    addChild(node)
                } else if letter == "v"  {
                    // load vortex
                    node = spriteNodes.createVortex(in: position)
                    addChild(node)
                } else if letter == "s"  {
                    // load star
                    node = spriteNodes.createStar(in: position)
                    addChild(node)
                } else if letter == "f"  {
                    // load finish
                    node = spriteNodes.createFlag(in: position)
                    addChild(node)
                } else if letter == " " {
                    // this is an empty space – do nothing!
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    
}

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
        #if targetEnvironment(simulator)
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
        #endif
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1

            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])

            if score >= 0 {
                player.run(sequence) { [weak self] in
                    self?.player = self?.spriteNodes.createPlayer()
                    self?.addChild((self?.player)!)
                    self?.isGameOver = false
                }
            } else {
                player.run(sequence)
                finishLevel()
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            // next level?
            isGameOver = true
            finishLevel()
        }
    }
    
    func finishLevel() {
        scoreLabel.removeFromParent()
        gameOverLabel = spriteNodes.addGameOverLabel()
        addChild(gameOverLabel)
    }
}
