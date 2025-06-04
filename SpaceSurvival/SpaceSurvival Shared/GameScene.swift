//
//  GameScene.swift
//  SpaceSurvival iOS
//

import SpriteKit

final class GameScene: SKScene {
    
    // MARK: - Nós principais
    private var player: SKSpriteNode!
    private var enemies: [SKSpriteNode] = []
    private var bullets: [SKSpriteNode] = []
    
    // MARK: - HUD
    private var heartNodes: [SKSpriteNode] = []
    private var timeLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    
    // MARK: - Estado do jogo
    private var lives = 3 {
        didSet { updateHearts() }
    }
    private var score = 0 {
        didSet { scoreLabel.text = "Pontos: \(score)" }
    }
    private var startTime: TimeInterval = 0
    
    // MARK: - Constantes
    private let playerSpeed: CGFloat     = 400
    private let enemySpeed: CGFloat      = 150
    private var spawnInterval: TimeInterval = 1.0
    private let spawnDecrease: TimeInterval = 0.02
    private let spawnMin: TimeInterval      = 0.35
    
    private let bulletInterval: TimeInterval = 0.5
    private let bulletSpeed: CGFloat         = 300
    
    // Controlo de tempo
    private var lastSpawn:      TimeInterval = 0
    private var lastUpdate:     TimeInterval = 0
    private var lastSecondCount: TimeInterval = 0
    private var lastBulletSpawn: TimeInterval = 0
    
    // MARK: - Setup
    override func didMove(to view: SKView) {
        // 0) Faz o (0,0) ser o CENTRO da cena
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // 1) Fundo
        let bg = SKSpriteNode(imageNamed: "background")
        bg.zPosition = -1
        bg.position  = .zero
        bg.size      = size
        addChild(bg)
        
        // 2) Jogador
        let texPlayer = SKTexture(imageNamed: "spaceship_green")
        player = SKSpriteNode(texture: texPlayer)
        rescale(node: player, desiredWidthRatio: 0.12)
        player.position = CGPoint(x: 0, y: -size.height * 0.4)
        addChild(player)
        
        // Corpo físico retangular (evita erro de textura grande)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = 1
        
        physicsWorld.contactDelegate = self
        
        // 3) Câmera + HUD
        let cam = SKCameraNode()
        camera = cam
        addChild(cam)
        
        // Espaçamento maior do topo
        let hudYOffset: CGFloat = 80
        
        // Hearts (vidas) à esquerda
        for i in 0..<3 {
            let heart = SKSpriteNode(imageNamed: "heart")
            rescale(node: heart, desiredWidthRatio: 0.06)
            let xPos = -size.width/2 + 20 + CGFloat(i) * (heart.size.width + 10)
            heart.position = CGPoint(x: xPos, y: size.height/2 - hudYOffset)
            heart.zPosition = 5
            cam.addChild(heart)
            heartNodes.append(heart)
        }
        
        // Time no meio
        timeLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        timeLabel.fontSize  = 22
        timeLabel.fontColor = .white
        timeLabel.text      = "Tempo: 0 s"
        timeLabel.position  = CGPoint(x: 0, y: size.height/2 - hudYOffset)
        timeLabel.zPosition = 5
        cam.addChild(timeLabel)
        
        // Score à direita
        scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.fontSize  = 22
        scoreLabel.fontColor = .white
        scoreLabel.text      = "Pontos: 0"
        scoreLabel.position  = CGPoint(x: size.width/2 - 100, y: size.height/2 - hudYOffset)
        scoreLabel.zPosition = 5
        cam.addChild(scoreLabel)
        
        // 4) Marca tempo inicial
        startTime        = CACurrentMediaTime()
        lastUpdate       = startTime
        lastSpawn        = startTime
        lastSecondCount  = startTime
        lastBulletSpawn  = startTime
    }
    
    // MARK: - Spawning
    private func spawnEnemy() {
        let texEnemy = SKTexture(imageNamed: "spaceship_red")
        let enemy    = SKSpriteNode(texture: texEnemy)
        rescale(node: enemy, desiredWidthRatio: 0.10)
        
        let halfW = size.width / 2
        let xPos  = CGFloat.random(in: -halfW ... halfW)
        enemy.position = CGPoint(x: xPos, y: size.height/2 + enemy.size.height)
        enemy.zRotation = .pi
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = 2
        enemy.physicsBody?.contactTestBitMask = 1 | 4
        
        addChild(enemy)
        enemies.append(enemy)
    }
    
    private func spawnBullet() {
        let texBullet = SKTexture(imageNamed: "bullet")
        let bullet    = SKSpriteNode(texture: texBullet)
        rescale(node: bullet, desiredWidthRatio: 0.03)
        
        // Posição: na ponta do player
        bullet.position = CGPoint(
            x: player.position.x,
            y: player.position.y + player.size.height/2 + bullet.size.height/2
        )
        bullet.zRotation = 0
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = 4
        bullet.physicsBody?.contactTestBitMask = 2
        
        addChild(bullet)
        bullets.append(bullet)
    }
    
    // MARK: - Update loop
    override func update(_ currentTime: TimeInterval) {
        let dt = currentTime - lastUpdate
        lastUpdate = currentTime
        
        // 1) Atualiza tempo de sobrevivência e pontuação por segundo
        let elapsed = currentTime - startTime
        if currentTime - lastSecondCount >= 1.0 {
            lastSecondCount += 1.0
            score += 1
        }
        timeLabel.text = "Tempo: \(Int(elapsed)) s"
        
        // 2) Spawn de inimigos
        if currentTime - lastSpawn > spawnInterval {
            spawnEnemy()
            lastSpawn      = currentTime
            spawnInterval  = max(spawnMin, spawnInterval - spawnDecrease)
        }
        
        // 3) Spawn de tiros automáticos
        if currentTime - lastBulletSpawn > bulletInterval {
            spawnBullet()
            lastBulletSpawn = currentTime
        }
        
        // 4) Move inimigos para baixo
        for enemy in enemies {
            enemy.position.y -= enemySpeed * CGFloat(dt)
        }
        
        // 5) Move balas para cima
        for bullet in bullets {
            bullet.position.y += bulletSpeed * CGFloat(dt)
        }
        
        // 6) Remove inimigos que saíram do ecrã (somam +5 pontos)
        enemies.removeAll { e in
            if e.position.y < -size.height/2 - e.size.height {
                e.removeFromParent()
                score += 5
                return true
            }
            return false
        }
        
        // 7) Remove balas que saíram do ecrã
        bullets.removeAll { b in
            if b.position.y > size.height/2 + b.size.height {
                b.removeFromParent()
                return true
            }
            return false
        }
    }
    
    // MARK: - Controlo tátil (movimento lateral)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let loc      = t.location(in: self)
        let targetX  = loc.x.clamped(to: -size.width/2 ... size.width/2)
        let dist     = abs(targetX - player.position.x)
        let duration = TimeInterval(dist / playerSpeed)
        
        player.removeAllActions()
        player.run(SKAction.moveTo(x: targetX, duration: duration))
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMoved(touches, with: event)
    }
    
    // MARK: - Utilitário de escala
    private func rescale(node: SKSpriteNode, desiredWidthRatio r: CGFloat) {
        let desired = size.width * r
        let scale   = desired / node.size.width
        node.setScale(scale)
    }
}

// MARK: - Colisão
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let aMask = contact.bodyA.categoryBitMask
        let bMask = contact.bodyB.categoryBitMask
        let combined = aMask | bMask
        
        // 1 = player, 2 = enemy, 4 = bullet
        if combined == 3 { // player(1) × enemy(2)
            if aMask == 2 { contact.bodyA.node?.removeFromParent() }
            else { contact.bodyB.node?.removeFromParent() }
            if let idx = enemies.firstIndex(where: { $0.parent == nil }) {
                enemies.remove(at: idx)
            }
            lives -= 1
            if lives <= 0 { gameOver() }
        }
        else if combined == 6 { // bullet(4) × enemy(2)
            if aMask == 2 {
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyB.node?.removeFromParent()
                contact.bodyA.node?.removeFromParent()
            }
            if let eIdx = enemies.firstIndex(where: { $0.parent == nil }) {
                enemies.remove(at: eIdx)
            }
            if let bIdx = bullets.firstIndex(where: { $0.parent == nil }) {
                bullets.remove(at: bIdx)
            }
            score += 5
        }
    }
    
    private func gameOver() {
        isPaused = true
        let lbl = SKLabelNode(text: "GAME OVER")
        lbl.fontName = "Arial-BoldMT"
        lbl.fontSize = 48
        lbl.fontColor = .red
        lbl.zPosition = 10
        lbl.position = .zero
        camera?.addChild(lbl)
    }
}

// MARK: - Extensão p/ limitar valores
private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Atualização de corações (vidas)
private extension GameScene {
    func updateHearts() {
        // Remove todos os corações atuais
        for heart in heartNodes { heart.removeFromParent() }
        heartNodes.removeAll()
        
        // Desenha de novo conforme o número de vidas
        for i in 0..<lives {
            let heart = SKSpriteNode(imageNamed: "heart")
            rescale(node: heart, desiredWidthRatio: 0.06)
            let xPos = -size.width/2 + 20 + CGFloat(i) * (heart.size.width + 10)
            heart.position = CGPoint(x: xPos, y: size.height/2 - 80)
            heart.zPosition = 5
            camera?.addChild(heart)
            heartNodes.append(heart)
        }
    }
}
