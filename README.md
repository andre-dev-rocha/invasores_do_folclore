# Invasores do Folclore

> Um jogo de nave estilo shoot 'em up ambientado no folclore brasileiro, onde o Capitão Zé Galáxia enfrenta criaturas lendárias transformadas em invasores cósmicos.

---

## Sobre o Jogo

**Invasores do Folclore** é um projeto desenvolvido em **Godot 4.6** por uma equipe colaborativa. O jogador controla a nave do Capitão Zé Galáxia e precisa sobreviver a ondas de inimigos inspirados no folclore brasileiro — do Saci Pererê ao Boto Cor-de-Rosa e à temida Mula Sem Cabeça.

Cada fase possui sua própria narrativa introduzida por diálogos em estilo cordel, antes de o combate começar. Entre as fases, o jogador visita a **Oficina de Upgrades**, onde pode melhorar sua nave usando sucatas coletadas em batalha.

---

## Tecnologia

| Item | Detalhe |
|---|---|
| Engine | Godot 4.6 (Forward+) |
| Linguagem | GDScript |
| Resolução | 960 × 720 px |
| Plataforma-alvo | PC (Windows / Linux) |

---

## Link do Jogo

O projeto completo e pronto para execução está disponível no seguinte link:

[Baixe o jogo clicando aqui](https://drive.google.com/file/d/1eG3BPshkzqIYxSoYbPClsAv4IYkRvzuH/view?usp=sharing)

---

## Como Rodar

1. Instale o [Godot 4.6](https://godotengine.org/download)
2. Clone o repositório:
   ```bash
   git clone https://github.com/andre-dev-rocha/invasores_do_folclore.git
   ```
3. Ou utilize diretamente o arquivo `invasores_do_folclore\jogo_completo_para_executar.zip` — extraia e abra a pasta no Godot
4. No Godot, clique em **Import** e selecione a pasta do projeto
5. Pressione **F5** ou clique em **Executar** para jogar

---

## Controles

| Ação | Tecla |
|---|---|
| Mover | Setas direcionais ou `A` / `D` / `W` / `S` |
| Atirar | `Espaço` |
| Escudo | `Shift` |
| Pausar | `Esc` |
| Avançar diálogo | `Espaço` |

---

## Estrutura do Projeto

```
invasores_do_folclore/
├── assets/
│   ├── audio/
│   │   ├── music/          # Trilhas das fases (track 1–9.ogg)
│   │   └── sfx/            # Efeitos sonoros (disparo, explosão, escudo)
│   ├── backgrounds/        # Fundos parallax e arte da loja de upgrades
│   └── sprites/
│       ├── enemies/        # Spritesheets dos inimigos e retratos
│       └── player/         # Nave do jogador, escudo, foguetes, munição
├── scenes/
│   ├── entities/           # Entidades do jogo (player, inimigos, projéteis, drops)
│   ├── levels/             # Cenas das fases (fase_1 a fase_4)
│   └── ui/                 # Menus, HUD, diálogos, loja, tela de vitória/game over
├── scripts/                # Lógica GDScript de todas as entidades e fases
└── jogo_completo_para_executar.zip  # ← Arquivo pronto para execução
```

---

## Fases

### Fase 1 — O Saci
- **Inimigo:** Saci Pererê
- **Ondas:** 5 (começa com 5 naves, +1 por onda)
- **Música:** Track 1
- **Mecânica:** Introdução ao jogo; naves do Saci entram pela lateral em movimento senoidal

### Fase 2 — O Boto
- **Inimigo:** Boto Cor-de-Rosa
- **Ondas:** 5 (começa com 6 naves, dificuldade progressiva)
- **Música:** Track 7
- **Mecânica:** Naves do Boto disparam projéteis em direção ao jogador

### Fase 3 — A Cuca Sideral
- **Inimigo:** Cuca Sideral (nave em formato de jacaré voador com caldeirão)
- **Narrativa:** Introduzida por sextilhas de cordel que descrevem a derrota do Boto e a chegada da nova ameaça; seguida de diálogo com retratos (estilo visual novel) entre o Capitão Zé Galáxia e a Cuca
- **Mecânica:** As naves nascem no topo da tela em posições aleatórias e descem com movimento sinuoso (função seno), similar ao nado; disparam projéteis radioativos verdes
- **Drops:** Alta chance de dropar sucata espacial e munição ao ser destruída

### Fase 4 — A Mula Sem Cabeça
- **Inimigo:** Mula Sem Cabeça
- **Ondas:** 5 (começa com 8 naves, +2 por onda)
- **Música:** Track 9
- **Narrativa:** O cenário muda drasticamente — após a névoa tóxica da Cuca, o espaço se incendeia com a chegada da Mula Sem Cabeça; diálogo com retratos antes do combate
- **Mecânica:** Naves entram pelos lados com movimento de galope (senoidal vertical); atacam com Spread Shot Triplo; caixas de munição surgem a cada 10 segundos
- **Status:** 4 vidas; recompensa de 400 pontos

---

## Sistemas

### Jogador — Capitão Zé Galáxia
- **Vidas:** 3 (expansível via upgrade)
- **Munição:** 40 inicial / 80 máximo
- **Escudo:** Ativável por tempo limitado com cooldown
- **Coleta:** Sucatas espaciais (moeda) e caixas de munição (+25 balas)

### Singleton Global
O autoload `Global` (`scripts/global.gd`) persiste entre cenas e gerencia:
- Nível dos upgrades (cadência, resistência, velocidade, escudo)
- Total de sucatas coletadas
- Checkpoint de sucatas por fase (restaurado no retry)
- Progressão entre fases via `ir_para_proxima_historia()`

### Loja de Upgrades (Oficina)
Acessada entre fases via tela de vitória. Permite comprar melhorias usando sucatas:

| Upgrade | Efeito | Custo (por nível) |
|---|---|---|
| Cadência | Reduz 20% o tempo entre tiros | 20 / 50 / 100 sucatas |
| Durabilidade | +1 vida por nível | 20 / 50 / 100 sucatas |
| Velocidade | +20% velocidade da nave | 20 / 50 / 100 sucatas |
| Escudo | +2s de duração do escudo | 20 / 50 / 100 sucatas |

Cada upgrade tem 3 níveis máximos.

### Sistema de Drops
- **Sucata Espacial:** cai ao matar inimigos; coletada por contato
- **Caixa de Munição:** spawna periodicamente na fase 4; recarrega 25 balas

### Vitória e Game Over
- **Vitória:** navega dinamicamente para a cena configurada em `Vitoria.proxima_cena` (loja ou menu)
- **Game Over:** permite tentar novamente (pulando a intro) ou voltar ao menu principal

---

## Fluxo de Jogo

```
Menu Principal
     │
     ▼
Cordel / Introdução da Fase
     │
     ▼
Diálogo (narrativa com o inimigo)
     │
     ▼
Combate em Ondas
     │
   ┌─┴─┐
Game  Vitória
Over    │
  │     ▼
  │  Loja de Upgrades
  │     │
  └──► Próxima Fase / Menu Principal
```

---

## Inimigos

| Inimigo | Cena | Script | Vidas | Pontos |
|---|---|---|---|---|
| Saci | `saci.tscn` | `saci.gd` | — | — |
| Boto | `boto.tscn` | `boto.gd` | — | — |
| Cuca Sideral | `cuca.tscn` | `cuca.gd` | — | — |
| Mula Sem Cabeça | `mula_sem_cabeca.tscn` | `mula_sem_cabeca.gd` | 4 | 400 |

---

## Equipe

| Colaborador | Contribuições |
|---|---|
| andre-dev-rocha | Arquitetura geral, sistema de upgrades, drops |
| AlcivanLucas | Fase 4 (Mula Sem Cabeça), fixes de autoload e vitória |
| heitorviana-dev | Sprites e assets visuais |
| Moura1980 | Contribuições gerais |
| cerqueirav77 | Contribuições gerais |
| CarlosEugenio177 | Contribuições gerais |
| apollo920 | Contribuições gerais |

---

## Contribuindo

1. Crie um branch a partir de `main`:
   ```bash
   git checkout -b feat/nome-da-feature
   ```
2. Faça suas alterações e commit:
   ```bash
   git commit -m "feat: descrição clara da mudança"
   ```
3. Abra um Pull Request descrevendo o que foi feito

### Convenção de commits
- `feat:` nova funcionalidade
- `fix:` correção de bug
- `chore:` tarefas de manutenção (imports, configs)
- `assets:` adição ou ajuste de sprites/áudio

---

## Licença

Projeto acadêmico/educacional. Todos os sprites e músicas são de uso interno da equipe.
