//
//  GameScene.swift
//  Project26
//
//  Created by Álvaro Ávalos Hernández on 20/10/20.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        loadLevel()
    }
    
    ///La propiedad categoryBitMask es un número que define el tipo de objeto para considerar colisiones.
    ///La propiedad collisionBitMask es un número que define con qué categorías de objeto debe colisionar este nodo,
    ///La propiedad contactTestBitMask es un número que define las colisiones sobre las que queremos ser notificados.
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }

        let lines = levelString.components(separatedBy: "\n")
        let spriteNodes = SpriteNodes()
        var node = SKSpriteNode()
        node = spriteNodes.createBackground()
        addChild(node)

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
