# 🚀 SpaceSurvival

Um jogo de sobrevivência no espaço desenvolvido em Swift usando SpriteKit para iOS.

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)
![SpriteKit](https://img.shields.io/badge/SpriteKit-Framework-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 📖 Sobre o Jogo

SpaceSurvival é um jogo de arcade espacial onde o jogador controla uma nave que deve sobreviver a ondas infinitas de inimigos. O objetivo é simples: sobreviva o máximo de tempo possível, destrua inimigos para ganhar pontos e colete power-ups para recuperar vidas.

### ✨ Características Principais

- 🎮 **Controle Intuitivo**: Movimentação tátil suave e responsiva
- 🔫 **Disparo Automático**: Projéteis são disparados automaticamente
- 👾 **Três Tipos de Inimigos**: Cada um com HP e velocidade diferentes
- ❤️ **Sistema de Vidas**: Comece com 3 vidas, colete corações para recuperar
- 📈 **Dificuldade Progressiva**: O jogo fica mais difícil com o tempo
- 🏆 **Sistema de Pontuação**: Ganhe pontos por tempo de sobrevivência e inimigos destruídos
- 🎨 **Visual Limpo**: Interface moderna com tema espacial

## 🎯 Como Jogar

1. **Movimento**: Toque e arraste na tela para mover a nave horizontalmente
2. **Disparo**: A nave dispara automaticamente a cada 0.5 segundos
3. **Sobrevivência**: Evite colidir com inimigos para não perder vidas
4. **Power-ups**: Colete corações vermelhos para recuperar vidas
5. **Pontuação**: 
   - +1 ponto por segundo de sobrevivência
   - +5 pontos por inimigo destruído
   - +5 pontos por inimigo que sai da tela

## 🛠️ Tecnologias Utilizadas

- **Linguagem**: Swift 5.0+
- **Framework**: SpriteKit
- **Plataforma**: iOS 13.0+
- **IDE**: Xcode 12.0+

## 📱 Requisitos do Sistema

- iOS 13.0 ou superior
- iPhone/iPad compatível
- Xcode 12.0+ (para desenvolvimento)

## 🚀 Instalação e Execução

### Pré-requisitos

- macOS com Xcode instalado
- Conta de desenvolvedor Apple (para testar em dispositivo físico)

### Passos para Instalação

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/seu-usuario/SpaceSurvival.git
   cd SpaceSurvival
   ```

2. **Abra o projeto no Xcode**:
   ```bash
   open SpaceSurvival.xcodeproj
   ```

3. **Configure o Team de Desenvolvimento**:
   - Selecione o projeto no navegador
   - Vá para "Signing & Capabilities"
   - Selecione seu Team de desenvolvimento

4. **Execute o projeto**:
   - Selecione um simulador ou dispositivo
   - Pressione `Cmd + R` ou clique no botão Play

## 🏗️ Estrutura do Projeto

```
SpaceSurvival/
├── GameScene.swift          # Classe principal do jogo
├── GameViewController.swift # Controlador da view
├── Assets.xcassets/        # Recursos visuais
│   ├── spaceship_green     # Sprite do jogador
│   ├── spaceship_1         # Inimigo fraco
│   ├── spaceship_2         # Inimigo médio  
│   ├── spaceship_3         # Inimigo forte
│   ├── bullet              # Projétil
│   ├── heart               # Power-up de vida
│   └── background          # Fundo do jogo
├── Info.plist              # Configurações do app
└── README.md               # Este arquivo
```

## 🎮 Mecânicas do Jogo

### Tipos de Inimigos

| Tipo | HP | Velocidade | Probabilidade | Cor |
|------|----|-----------|--------------|----|
| Fraco | 1 | 100% | 60% | Vermelho |
| Médio | 2 | 75% | 25% | Laranja |
| Forte | 3 | 50% | 15% | Roxo |

### Sistema de Pontuação

- **Sobrevivência**: 1 ponto por segundo
- **Inimigo Destruído**: 5 pontos
- **Inimigo Escapou**: 5 pontos (bônus por sobrevivência)

### Dificuldade Progressiva

- **Intervalo Inicial**: 1.0 segundo entre spawns
- **Diminuição**: 0.02 segundos por spawn
- **Intervalo Mínimo**: 0.35 segundos

## 🔧 Arquitetura do Código

### Principais Classes e Métodos

- **GameScene**: Classe principal que herda de `SKScene`
  - `didMove(to:)`: Inicialização da cena
  - `setupScene()`: Configuração dos elementos visuais
  - `update(_:)`: Loop principal do jogo (60 FPS)
  - `spawnEnemy()`: Criação de inimigos
  - `handleCollisions()`: Tratamento de colisões

### Padrões de Design Utilizados

- **Observer Pattern**: Property observers (`didSet`)
- **Delegate Pattern**: `SKPhysicsContactDelegate`
- **Factory Pattern**: Métodos de spawn
- **Extension Pattern**: Organização do código

### Conceitos Avançados

- **Property Observers**: Atualização automática da UI
- **Physics System**: Detecção de colisões com SpriteKit
- **Delta Time**: Movimentação suave independente do FPS
- **Memory Management**: Limpeza automática de objetos

## 🎨 Assets Necessários

O jogo requer os seguintes assets na pasta `Assets.xcassets`:

- `spaceship_green`: Nave do jogador
- `spaceship_1`, `spaceship_2`, `spaceship_3`: Naves inimigas
- `bullet`: Projétil
- `heart`: Power-up de vida
- `background`: Fundo espacial

## 🤝 Como Contribuir

1. **Fork** o projeto
2. **Crie** uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. **Commit** suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. **Push** para a branch (`git push origin feature/nova-feature`)
5. **Abra** um Pull Request

### Ideias para Contribuições

- 🎵 Sistema de áudio (efeitos sonoros e música)
- ✨ Efeitos visuais (partículas, explosões)
- 🏆 Sistema de conquistas
- 💾 Persistência de dados (high scores)
- 🎯 Novos tipos de power-ups
- 🤖 Inimigos com IA mais avançada
- 📱 Suporte para múltiplas resoluções

## 🐛 Problemas Conhecidos

- Nenhum problema conhecido no momento

## 📝 Changelog

### v1.0.0 (Atual)
- ✅ Implementação básica do jogo
- ✅ Sistema de colisões
- ✅ Três tipos de inimigos
- ✅ Sistema de vidas e pontuação
- ✅ Dificuldade progressiva
- ✅ Power-ups de vida

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Seu Nome**
- GitHub: [@NunoIsidoro](https://github.com/NunoIsidoro)

## 📚 Recursos Adicionais

- [Documentação do SpriteKit](https://developer.apple.com/documentation/spritekit)
- [Guia da Linguagem Swift](https://docs.swift.org/swift-book/)
- [Ray Wenderlich - Tutoriais de Jogos iOS](https://www.raywenderlich.com/ios/games)

---

⭐ **Se gostou do projeto, deixe uma estrela!** ⭐

