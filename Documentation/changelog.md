# Dice Poker — Changelog / Log de Desenvolvimento

> Este documento regista cada iteração, melhoria, erro detectado e respectiva correcção ao longo do desenvolvimento do projecto.

---

## Iteração 19 — Achievements implementados + Ecrã About + Deploy (12 de Maio de 2026)

### [FEATURE] 5 achievements implementados (anteriormente pendentes)
- `invictus` — Vencer sem o adversário alguma vez estar na frente
- `clutchScorer` (Tudo ou Nada) — Vencer estando a perder por 50+ pontos antes do último turno
- `strategist` (Estratega) — Completar um jogo sem marcar 0 em nenhuma célula de figura
- `survivor` → renomeado para **Última Oportunidade** — Vencer quando o adversário estava na frente no último turno
- `chameleon` (Camaleão) — Ganhar pelo menos um jogo contra cada perfil de IA

### [FEATURE] Tracking de score snapshots em jogo
- `lib/ui/game_screen.dart` — `_scoreSnapshots` gravado a cada mudança de jogador
- `processCompletedMatch` recebe novo parâmetro `scoreSnapshots` para avaliar Invictus/TudoOuNada/ÚltimaOportunidade
- Nova chave SharedPreferences: `achievements.profilesBeaten.v1` para Camaleão

### [FEATURE] Ecrã About
- Novo ficheiro `lib/ui/about_screen.dart`
- Acessível via ícone `info_outline` no AppBar do SetupScreen (primeira posição, à esquerda dos outros ícones)
- Conteúdo: versão da app, descrição, link mailto para feedback, link para fonte das regras originais
- Fonte das regras: https://vamosokintressa.blogspot.com/2008/08/regras-tradicionais-portuguesas-do.html

### [FEATURE] Novos strings i18n (7 idiomas)
- `aboutTitle`, `feedbackLabel`, `rulesSourceLabel`, `aboutVersionLabel`, `aboutAppDescription`

### [DEPS] url_launcher ^6.3.0 adicionado ao pubspec.yaml

### [FIX] Regras in-app: tabelas simplificadas (mono-língua) + Pilo → Noves em PT
- Todos os 7 ficheiros `assets/rules/*.md` actualizados

---

## Iteração 18 — i18n 7 idiomas + Documentação Traduzida + Decisões de Produto (24 de Abril de 2026)

### [FEATURE] Internacionalização completa para 7 idiomas
- `lib/ui/i18n/app_strings.dart` reescrito com enum `AppLang { en, ptPT, ptBR, es, fr, de, it }`
- Todos os strings de UI + títulos/descrições de 40 achievements traduzidos nos 7 idiomas
- Novos strings: `achievements`, `achievementsUnlocked`, `pendingSuffix`, `close`, `language`, `languageScreenTitle`, `languageSystemDefault`

### [FEATURE] Selector de idioma
- `lib/ui/services/locale_service.dart` — persiste locale escolhido via `shared_preferences` (chave `app.locale.v1`)
- `lib/ui/language_screen.dart` — ecrã dedicado com lista de 7 idiomas (flag + nome nativo + checkmark)
- `LocaleController` InheritedWidget em `main.dart` — expõe `setLocale(Locale?)` pelo widget tree
- `Dice PokerApp` tornado stateful; carrega locale guardado no `initState`
- Botão 🌐 no AppBar do `SetupScreen` → abre `LanguageScreen`
- `SetupScreen`: achievements dialog e botão Achievements totalmente localizados

### [DOCS] Documentação traduzida (×6 idiomas + EN)
- `game_rules.md` (PT-PT) + `game_rules_pt_br.md`, `game_rules_es.md`, `game_rules_fr.md`, `game_rules_de.md`, `game_rules_it.md`
- `user_manual.md` (PT-PT) + `user_manual_pt_br.md`, `user_manual_es.md`, `user_manual_fr.md`, `user_manual_de.md`, `user_manual_it.md`

### [PRODUCT] Decisões de produto registadas
- `Documentation/PENDING_DECISIONS.md` criado — regista todas as decisões em aberto
- Roadmap aprovado: Web → Android → Multiplayer → Monetização → iOS
- Modelo de monetização: freemium por feature gating, sem anúncios durante o jogo
- Multiplayer: Supabase Realtime (tempo real + turnos assíncronos), sala com código

### [INFRA] Totais
- **117 testes** — todos a passar

---

## Iteração 17 — Fix: Dados Bloqueados Persistem Entre Lançamentos (23 de Abril de 2026)

### [FIX] Seleção de dados mantida após HoldDice
- **Problema**: `_selectedDice.clear()` era chamado incondicionalmente em `_performActionWithRoll`, o que limpava a seleção visual mesmo após um `HoldDice` — os dados bloqueados deixavam de aparecer selecionados no lançamento seguinte
- **Correcção**: A seleção só é limpa se a ação não for `HoldDice` ou se o jogador mudou
- **Ficheiro**: `lib/ui/game_controller.dart`

### [INFRA] Totais
- **117 testes** — todos a passar

---

## Iteração 16 — Mixed-Fair 100000 Jogos (23 de Abril de 2026)

### [ANALYSIS] Corrida larga para validação de estabilidade
- Comando: `dart run tool/stress_simulation.dart --games 100000 --mode mixed-fair`
- Runs: `20260423_004229` e `20260423_004359`
- Integridade: 100000 jogos completos, 0 erros

### [ANALYSIS] Resultados consolidados por perfil
- **aggressive**: 34.911% win rate, avg score 856.168
- **balanced**: 29.248% win rate, avg score 828.154
- **cautious**: 26.918% win rate, avg score 811.262
- **dreamer**: 8.923% win rate, avg score 642.418

### [ANALYSIS] Métricas globais da corrida
- avg moves/game: 415.901
- avg ms/game: ~1.94 a ~2.13 (dependente da execução)
- combos por jogo:
  - poker: 4.73773
  - sequence: 8.62572
  - full: 11.00559

### [CONCLUSION] Estado de balanceamento
- Ranking competitivo estável: aggressive > balanced > cautious >>> dreamer
- Dreamer permanece válido como perfil temático, mas sub-balanceado para competição mista

---

## Iteração 15 — Dreamer Profile + Fair Sim Modes (23 de Abril de 2026)

### [FEATURE] Novo perfil AI: Dreamer (Sonhador)
- Adicionado `AiProfile.dreamer`
- Estratégia:
  - prioriza poker acima de tudo
  - aceita jogadas não-poker quando surgem de mão
- Integração em setup/i18n (`AppStrings.aiProfileName`)

### [FEATURE] Modos de simulação para comparação justa
- `tool/stress_simulation.dart` expandido com:
  - `--mode mirror --profile <perfil>` (4 jogadores com o mesmo perfil)
  - `--mode mixed-fair` (balanced/aggressive/cautious/dreamer com rotação de seats)
- Configuração da corrida passa a incluir `mode` e `mirror_profile`

### [TEST] Cobertura adicional
- Novos testes em `test/engine/ai_profiles_test.dart` para comportamento do Dreamer

### [ANALYSIS] Bateria executada (1000 jogos por cenário)
- Corridas mirror: balanced, aggressive, cautious, dreamer
- Corrida mixed-fair com rotação
- Observação principal: Dreamer performa significativamente pior em mixed-fair face aos restantes perfis

### [INFRA] Totais
- **117 testes** — todos a passar

---

## Iteração 14 — Stress Simulation + Stats (23 de Abril de 2026)

### [FEATURE] Runner de testes de exaustão
- Novo script: `tool/stress_simulation.dart`
- Simulação massiva no engine (sem UI) com AI profiles
- Suporte a argumentos:
  - `--games` (default 1000)
  - `--seed` (reprodutibilidade)
  - `--max-moves` (safety cap)

### [FEATURE] Export de estatísticas
- Saída por corrida em `output/simulations/`:
  - JSON detalhado (`<run_id>.json`)
  - CSV resumo por perfil (`<run_id>_summary.csv`)
- Métricas exportadas:
  - vitórias por perfil e por seat
  - score médio/mediana/desvio padrão por perfil
  - frequência de poker/sequence/full (incluindo fromHand)
  - moves médios por jogo e tempo médio por jogo
  - taxa de jogos válidos e número de erros

### [FIX] Serialização JSON
- Corrigido export de `wins.by_seat` para usar chaves string (compatível com JSON)

### [INFRA] Totais
- **115 testes** — todos a passar
- **Ficheiros novos**: `tool/stress_simulation.dart`

---

## Iteração 13 — Cleanup de Legado (23 de Abril de 2026)

### [REFACTOR] Remoção de widget antigo
- Removido `lib/ui/widgets/dice_area.dart` (legado)
- A aplicação já usava `dice_3d.dart` como única implementação ativa de dados
- Eliminação de código morto para reduzir manutenção futura

### [INFRA] Totais
- **115 testes** — todos a passar
- **Ficheiros removidos**: `lib/ui/widgets/dice_area.dart`

---

## Iteração 12 — Achievements + Milestones (23 de Abril de 2026)

### [FEATURE] Sistema de achievements (persistente)
- Novo serviço `lib/ui/services/achievements_service.dart`
- Processamento automático no fim de cada jogo (game over)
- Estado guardado localmente com:
  - achievements desbloqueados
  - contadores cumulativos
  - streak de vitórias humanas
  - faces já vistas para 5 iguais

### [FEATURE] Milestones acumulativos adicionados
- **Poker total**: 10, 30, 50, 100, 200, 500
- **Sequências de mão** (fromHand): 100, 200, 500, 1000, 3000, 10000
- **Full house de mão** (fromHand): 100, 200, 500, 1000, 3000, 10000
- **5 iguais em todas as faces**: achievement desbloqueia quando as 6 faces já ocorreram como 5 iguais

### [FEATURE] UI de achievements
- Botão "Achievements" no setup
- Dialog com lista completa, estado lock/unlock e progresso de milestones
- Achievements "em aberto" explicitamente marcados para evolução futura

### [TEST] Cobertura adicional
- Novo ficheiro: `test/ui/services/achievements_service_test.dart`
- Casos cobertos:
  - milestone de poker
  - contagem fromHand para sequence/full
  - unlock de 5 iguais para 6 faces

### [INFRA] Totais
- **115 testes** — todos a passar
- **Ficheiros novos**: `lib/ui/services/achievements_service.dart`, `test/ui/services/achievements_service_test.dart`
- **Ficheiros alterados**: `lib/ui/game_screen.dart`, `lib/ui/setup_screen.dart`

---

## Iteração 11 — Visual Polish (Scorecard Totals) (23 de Abril de 2026)

### [IMPROVE] Totais sempre visíveis durante jogo
- Nova barra de resumo no topo da scorecard com:
  - totais por linha de figura (A/K/Q/J/10)
  - totais de especiais (Seq/Full/Poker)
  - **total geral** em destaque
- Cálculo reutiliza a lógica existente do engine (`calculateLineScore` + `calculateTotalScore`)

### [IMPROVE] Usabilidade da tabela
- Scroll vertical + horizontal na scorecard para melhor adaptação a diferentes alturas/larguras de ecrã
- Melhor hierarquia visual para leitura rápida de pontuações

### [INFRA] Totais
- **112 testes** — todos a passar
- **Ficheiros alterados**: `lib/ui/widgets/scorecard_table.dart`, `lib/ui/i18n/app_strings.dart`

---

## Iteração 10 — i18n EN/PT (23 de Abril de 2026)

### [FEATURE] Internacionalização base da UI
- `MaterialApp` configurado com:
  - `supportedLocales`: EN + PT
  - delegates (`GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, `GlobalCupertinoLocalizations`)
- Novo helper de strings: `lib/ui/i18n/app_strings.dart`
  - selecção por locale do dispositivo
  - suporte inicial a textos dinâmicos (turno, vencedor, labels com pontos)

### [IMPROVE] Cobertura de textos localizados
- `setup_screen.dart` — labels, botões, snackbars e nomes de perfis AI
- `game_screen.dart` — app bar, banner de turno, labels de lançamento/acumulação, game over/dialog
- `action_panel.dart` — botões/acções de jogo
- `scorecard_table.dart` — cabeçalhos e secção de especiais

### [INFRA] Totais
- **112 testes** — todos a passar
- **Ficheiros novos**: `lib/ui/i18n/app_strings.dart`
- **Ficheiros alterados**: `lib/main.dart`, `lib/ui/setup_screen.dart`, `lib/ui/game_screen.dart`, `lib/ui/widgets/action_panel.dart`, `lib/ui/widgets/scorecard_table.dart`, `pubspec.yaml`

---

## Iteração 9 — Responsive Layout (23 de Abril de 2026)

### [FEATURE] GameScreen responsivo (mobile vs desktop)
- Breakpoint para layout largo (desktop/tablet):
  - coluna esquerda: dados + painel de acções
  - coluna direita: tabs de jogador + scorecard
- Em mobile mantém stack vertical optimizada
- Banner do jogador com `Flexible` para evitar overflow de texto

### [FEATURE] SetupScreen responsivo
- Em ecrãs largos, cards de jogadores em grelha (`Wrap`)
- Em ecrãs pequenos, cards em coluna única
- Card de configuração adaptado com `Wrap` para melhor encaixe horizontal

### [INFRA] Totais
- **112 testes** — todos a passar
- **Ficheiros alterados**: `lib/ui/game_screen.dart`, `lib/ui/setup_screen.dart`

---

## Iteração 8 — Setup + Persistência (23 de Abril de 2026)

### [FEATURE] Setup Screen (pré-jogo)
- Novo ecrã de configuração antes de iniciar partida
- Escolha de **1 a 4 jogadores**
- Configuração por jogador:
  - Nome
  - Humano vs AI
  - Perfil de AI (Balanced, Aggressive, Cautious)
- `main.dart` passa a abrir o setup por defeito

### [FEATURE] Persistência de configuração (setup)
- Guardar/restaurar automaticamente em `shared_preferences`:
  - número de jogadores
  - nomes
  - flags AI
  - perfis AI

### [FEATURE] Persistência de partida (save/resume)
- Novo serviço: `lib/ui/services/game_persistence.dart`
- Serialização local de `GameState` + `aiProfiles`
- Botão **Continue Saved Game** no setup quando existe snapshot válido
- Auto-save contínuo durante o jogo
- Limpeza automática da partida guardada quando o jogo termina

### [REFACTOR] Controller/Game bootstrapping
- `GameController` agora suporta inicialização por `initialState` (retoma)
- `GameScreen` aceita `initialState` opcional e passa a hidratar o controller com estado guardado

### [INFRA] Totais
- **112 testes** — todos a passar
- **Ficheiros novos**: `lib/ui/setup_screen.dart`, `lib/ui/services/game_persistence.dart`
- **Ficheiros alterados**: `lib/main.dart`, `lib/ui/game_screen.dart`, `lib/ui/game_controller.dart`, `lib/engine/game_engine.dart`, `lib/engine/constants.dart`, `pubspec.yaml`, `test/widget_test.dart`

---

## Iteração 7 — Bug Fixes + Sound (18 de Abril de 2026)

### [FIX] Poker com 4 noves não era detectado
- **Problema**: `detectSpecialCombinations` excluía nines da detecção de poker — 4 nines + outra face não era oferecido
- **Correcção**: Removida a exclusão `if (face == DieFace.nine) continue` em `scoring.dart`
- **Teste**: Actualizado para verificar que 4 nines é detectado como Poker

### [FIX] HOLD badge persistia após scoring
- **Problema**: `_selectedDice` no GameController só era limpo na mudança de jogador — ao registar score no mesmo turno, os badges "HOLD" ficavam visíveis nos dados re-lançados
- **Correcção**: `_selectedDice.clear()` em todas as acções (`_performActionWithRoll` e `performAction`)

### [FEATURE] Linhas especiais fecham como as figure lines
- **Problema**: Sequências, Fulls e Pokers não tinham limite e não contavam para o fim de jogo
- **Correcção**:
  - Máximo de 5 entradas por linha especial (= `columnsPerLine`)
  - `closedSpecialLines: Set<SpecialLine>` + `closedSpecialBy: Map<SpecialLine, int>` no `GameState`
  - Quando um jogador preenche os 5 slots, a linha fecha para todos
  - `isGameOver()` conta figure + special lines (4 de 8 totais)
  - `getValidActions()` bloqueia scoring em linhas especiais fechadas
  - UI mostra riscado + fundo vermelho (igual às figure lines)
  - Entradas especiais mostradas em colunas individuais na tabela (não resumidas)

### [FEATURE] Som de dados real
- **Package**: `audioplayers ^6.1.0` — funciona em web + mobile
- **3 ficheiros WAV** gerados proceduralmente (`tool/generate_sounds.dart`):
  - `dice_roll.wav` (21 KB) — rattle de dados a rolar
  - `dice_land.wav` (6 KB) — thud quando pousam
  - `score.wav` (17 KB) — ding ao registar pontuação
- `DiceSoundService` reescrito com `AudioPlayer` + haptic feedback
- `Dice3DRow.onLanded` callback — toca som quando animação termina
- `ActionPanel.onScored` callback — toca som ao registar score

### [IMPROVE] Títulos de coluna simplificados
- Removidos "C1, C2, C3..." — agora mostram apenas "≥7", "≥6", "≥6", "≥8", "≥8"

### [INFRA] Totais
- **112 testes** (49 scoring + 54 game engine + 8 AI + 1 widget smoke) — todos a passar
- **6 novos testes de regressão**: held dice clearing, seq/full/poker close, special blocks others, special+figure game over
- **Ficheiros novos**: `tool/generate_sounds.dart`, `assets/audio/*.wav`
- **Ficheiros alterados**: `scoring.dart`, `game_engine.dart`, `game_controller.dart`, `game_screen.dart`, `scorecard_table.dart`, `action_panel.dart`, `dice_3d.dart`, `dice_sound.dart`, `pubspec.yaml`, `constants.dart`

---

## Iteração 6 — AI Profiles (17 de Abril de 2026)

### [FEATURE] Sistema de jogadores AI
- **Novo ficheiro**: `lib/engine/ai_profiles.dart` — lógica pura de decisão AI
- **3 perfis** com estratégias diferentes:
  - **Balanced** — maximiza valor esperado, equilibra score vs hold
  - **Aggressive** — persegue linhas de alto multiplicador, acumulação, e combos especiais
  - **Cautious** — minimiza risco, score cedo, finaliza acumulação assim que atinge mínimo
- **Arquitectura**: `chooseAction(GameState, AiProfile) → TurnAction`
  - Avalia todas as opções de scoring via `getValidActions()`
  - Calcula valor ponderado: pontos × multiplicador × bónus/penalty por perfil
  - Compara score imediato vs valor esperado de hold+re-roll
  - Handling especial para acumulação (continue vs finalize por perfil)
  - Detecção de near-straights (4 de 5 faces sequenciais)
  - Hold inteligente: mantém face mais frequente + nines

### [IMPROVE] Game Controller — integração AI
- `GameController` aceita `aiProfiles: Map<int, AiProfile>` — configura quais jogadores são AI
- Turno AI automático: quando é a vez de um jogador AI, executa acções com delays entre elas
  - 600ms antes da primeira acção (mostra mudança de jogador)
  - 900ms entre acções de rolling (animação de dados)
  - 500-700ms entre acções de scoring (pausa para o utilizador acompanhar)
- `aiPlaying` flag — desactiva interacção do utilizador durante turno AI
- `isCurrentPlayerAi` getter — UI adapta-se (banner diferente, etc.)

### [IMPROVE] UI — indicadores visuais de AI
- Banner do jogador muda de cor quando é AI (tertiaryContainer vs primaryContainer)
- Emoji 🤖 antes do nome de jogadores AI
- Texto "is thinking..." durante turno AI
- Selecção de dados desactivada durante turnos AI

### [INFRA] Totais
- **106 testes** (49 scoring + 48 game engine + 8 AI + 1 widget smoke) — todos a passar
- **Testes AI**: fresh state, all-match scoring, hold behaviour, last roll, accumulation continue/finalize, full game simulation (todos os 3 perfis)
- **Ficheiros novos**: `ai_profiles.dart`, `ai_profiles_test.dart`
- **Ficheiros alterados**: `game_controller.dart`, `game_screen.dart`

---

## Iteração 5 — Dice Polish + Game Over Screen (17 de Abril de 2026)

### [IMPROVE] Animação de dados — Scatter + Settle (3ª iteração)
- **Problema**: Iterações 3D com cubos (Matrix4 transforms) não ficavam convincentes no Flutter 2D canvas
- **Solução final**: Vista de cima — dados são atirados do topo e espalham-se pela mesa
- **Detalhes**:
  - Mesa verde com `RadialGradient` + borda castanha + textura feltro (dots)
  - Dados voam do centro-topo, spin flat (como piões), scale bounce ao pousar (1.3→0.95→1.05→1.0)
  - Tilt final aleatório (±3.5°) — como dados reais que não ficam perfeitamente planos
  - Sombra dinâmica: mais difusa durante voo, apertada quando assenta
  - Stagger: i*35 + random(25)ms por dado
  - Duração: 800ms

### [FIX] Dados não saltam de posição após animação
- **Problema**: Quando animação terminava, dados saltavam da posição jittered para posição fixa (`_settledPositions`)
- **Causa**: `_buildDie()` usava `animating ? anim.value : fixedPos` — quando `isAnimating` passava a false, snap
- **Solução**: Usar sempre `_posAnims[i].value` — a animação retém o valor final correcto

### [IMPROVE] Layout de dados — held à esquerda, rolling ao centro
- **Antes**: Todos os dados tinham posições fixas, podiam sobrepor-se
- **Agora**: Posições calculadas dinamicamente com `_computePositions()`:
  - Dados held agrupados à esquerda da mesa
  - Dados rolling agrupados ao centro
  - Espaçamento de 66px (56px dado + 10px gap) — sem sobreposição
  - Gap de 20px entre grupo held e grupo rolling

### [IMPROVE] Delay entre held slide e lançamento
- Quando há dados held, eles deslizam primeiro para a esquerda (easeInOut)
- Dados rolling só são lançados 350ms depois — sequência visual clara

### [IMPROVE] Held dice persistem entre rolls
- **Problema**: `_selectedDice` era limpo após cada `rollWithHeld()`
- **Solução**: Removido `_selectedDice.clear()` de `rollWithHeld()`, adicionada detecção de mudança de jogador em `_performActionWithRoll`/`performAction`

### [FEATURE] Ecrã de Game Over com vencedor
- **Dialog modal** aparece automaticamente quando jogo termina (4 de 5 linhas fechadas)
- Mostra 🏆 troféu + nome do vencedor
- Tabela de **pontuações finais** de todos os jogadores (usa `calculateTotalScore()`)
- Vencedor marcado com 👑 e pontuação em bold/verde
- Botão "New Game" para recomeçar
- Barra discreta em baixo do ecrã com "Game Over" + botão "New Game" (backup)

### [INFRA] Totais
- **98 testes** — todos a passar
- **Ficheiros alterados**: `dice_3d.dart` (reescrito 3×), `game_controller.dart`, `game_screen.dart`

---

## Iteração 4 — Accumulation Fix + 3D Dice (17 de Abril de 2026)

### [FIX] Modo de Acumulação reescrito
- **Problema**: Acumulação era um "modo declarado" pelo jogador (StartAccumulation), mas as regras reais dizem que é um trigger automático quando todos os 5 dados são a figura-alvo ou 9.
- **Antes**: Jogador escolhia "Accum Q" → entrava em modo → hold/roll → finalize.
- **Agora**: Jogador carrega no botão normal de scoring (ex: "Q 9pts"). Se todos os 5 dados forem Q ou 9, entra automaticamente em acumulação. Pode:
  - **Continue Accum** (re-roll all 5, mantendo running total) — disponível quando todos os dados continuam a ser a figura/9
  - **Hold + Roll** — segurar dados e relançar os restantes
  - **Finalize** — registar total acumulado na coluna (se ≥ mínimo)
  - **Pass** — auto-finalize
- **Removido**: `StartAccumulation` action — substituído por `ContinueAccumulation`
- **Spec**: game_specification.md §2.11, §4.3b actualizados
- **Testes**: 5 antigos reescritos + 5 novos testes (trigger, continue, hold, full flow, pass auto-finalize)
- **Total**: 98 testes, todos a passar

### [FEATURE] Dados 3D com animação de lançamento
- **Novo widget**: `lib/ui/widgets/dice_3d.dart` — `Dice3DRow`
- **Design**: Dados quadrados (64×64px) com bordas arredondadas, sombra 3D
- **Animação de roll**: Rotação rápida (2-4 voltas completas) com `Curves.easeOutCubic`, ~700ms
- **Staggered timing**: Cada dado inicia com offset ligeiramente diferente (0–90ms) para parecer natural
- **Dados segurados (HOLD)**: Ficam completamente parados enquanto os outros animam
- **Badge "HOLD"**: Aparece abaixo do dado seleccionado
- **Opacity**: Dados held ficam semi-transparentes (50%)

### [FEATURE] Som/Haptic de lançamento
- **Novo serviço**: `lib/ui/services/dice_sound.dart` — `DiceSoundService`
- **Mecânica**: Haptic feedback (light → light → medium) para simular dados a rolar
- **Sem dependências externas**: Usa `HapticFeedback` nativo do Flutter (funciona em mobile, no-op silencioso em web)

### [IMPROVE] Game Controller — rolling state
- Adicionado `isRolling` flag ao `GameController`
- Todas as acções que causam re-roll usam `_performActionWithRoll()` — activa flag, notifica listeners, reset após 750ms
- UI reage ao flag para disparar animação e som

### [REFACTOR] GameState.copyWith — nullable field clearing
- Adicionados `clearAccumulationTarget` e `clearAccumulationColumn` booleans
- Permite resetar campos nullable (antes `null ?? this.x` impedia reset)

### [INFRA] Totais
- **98 testes** (49 scoring + 48 game engine + 1 widget smoke) — todos a passar
- **Ficheiros novos**: `dice_3d.dart`, `dice_sound.dart`
- **Ficheiros alterados**: `game_engine.dart`, `game_controller.dart`, `game_screen.dart`, `action_panel.dart`
- **Ficheiro substituído**: `dice_area.dart` → `dice_3d.dart` (widget antigo mantido mas não usado)

---

## Legenda de Tags

- **[FEATURE]** — Nova funcionalidade
- **[FIX]** — Correcção de erro
- **[IMPROVE]** — Melhoria a funcionalidade existente
- **[INFRA]** — Alteração de infraestrutura / deploy
- **[REFACTOR]** — Reestruturação de código
- **[DOCS]** — Documentação

---

## Iteração 0 — Arranque do Projecto (15 de Abril de 2026)

### [DOCS] Definição do projecto
- Criação do resumo do projecto com visão geral, regras, arquitectura e tech stack.
- Identificação de 6 questões em aberto que precisam de resolução antes da implementação.
- Decisão de tech stack: Flutter (Dart) para codebase única Android + Web.

### [DOCS] Criação da pasta Documentation
- `Documentation/project_description.md` — descrição completa do projecto
- `Documentation/changelog.md` — este ficheiro
- `Documentation/last_session.md` — contexto para continuidade entre sessões

### [DOCS] Validação de regras contra fonte original
- Fonte: https://vamosokintressa.blogspot.com/2008/08/regras-tradicionais-portuguesas-do.html
- Correcção da notação: de inglesa (K,Q,J) para portuguesa (R,D,V,X)
- Adicionado: 9 é wildcard (vale 1 pt da figura em jogo)
- Adicionado: multiplicadores por figura (A×6, R×5, D×4, V×3, X×2)
- Adicionado: estrutura da tabela (5 colunas, mínimos 7/6/6/8/8)
- Adicionado: totais de sequências/fullens apenas se somam (não multiplicam)
- Adicionado: regra de fecho de linha e pontuação a dobrar
- Expandidas as variantes (Poker: 4 iguais de mão; Acumulação: soma na mesma coluna)
- Resolvidas questões A, B, D; adicionadas novas questões G, H

### [DOCS] Resolução de questões em aberto
- **E)** Turno = 3 lançamentos; se não marcar nada no turno completo, perde a vez
- **F)** MVP = 4 jogadores, local pass-and-play
- **G)** MVP usa regras base (sem variantes Poker ou Acumulação)
- **H)** Código em inglês; UI bilingue (EN + PT) com i18n desde o início
- Notação interna: A, K, Q, J, 10, 9 (inglês)
- Clarificação: entre lançamentos o jogador pode segurar dados OU marcar e recomeçar

### [DOCS] Especificação formal do jogo
- Criado `Documentation/game_specification.md` (v1.0 MVP)
- 10 secções: constants, scoring rules, line closing, turn flow, game flow, table layout, data model (Dart), scoring engine API, test cases, future extensions
- Definição exacta de enums, classes, constantes prontas para implementar
- 5 categorias de test cases de validação

### [FIX] Correcções à especificação (v1.1)
- **fromHand**: redefinido — não é só o 1º lançamento, mas qualquer lançamento onde todos os 5 dados são lançados (sem dados segurados). Pode acontecer nos rolls 1, 2 ou 3.
- **Sequências**: clarificado que a ordem/posição dos dados é irrelevante — apenas a presença das faces correctas conta.
- **Bónus de linha não aberta**: corrigido — apenas o jogador que FECHOU a linha dobra a pontuação; os outros que abriram ficam com pontuação normal.
- **Variantes incluídas nas regras base**: Poker (4 iguais de mão = 100pts, Poker Real = 200pts) e Acumulação (soma da mesma figura ao longo dos 3 lançamentos numa coluna) passam a fazer parte das regras MVP.
- Data model actualizado: novo enum `poker` em SpecialLine, `pokerEntries` em ScoreCard, tracking de acumulação em GameState, novas TurnActions.

## Iteração 1 — Motor de Jogo (Abril 2026)

### [FEATURE] Dart SDK + Projecto
- Instalado Dart SDK 3.11.4 via `winget install Google.DartSDK`
- Criado projecto Dart puro (`pubspec.yaml`, `analysis_options.yaml`)
- Barrel export: `lib/Dice Poker.dart`

### [FEATURE] Models & Scoring Engine
- `lib/engine/constants.dart` — constantes do jogo (§1, §7.3)
- `lib/engine/models.dart` — DieFace, FigureLine, SpecialLine, SpecialCombination (sealed), Die, ScoreCard, Player
- `lib/engine/scoring.dart` — 6 funções puras: calculateFigurePoints, detectSpecialCombinations, canScoreInLine, calculateLineScore, calculateTotalScore, isGameOver
- `test/engine/scoring_test.dart` — 49 testes unitários, todos a passar

### [FEATURE] Game State Engine
- `lib/engine/game_engine.dart` — gestão de estado completa:
  - `GameState` class (imutável, com `copyWith`)
  - `TurnAction` sealed hierarchy (9 acções: ScoreFigure, ScoreSpecialInFigure, ScoreSequence, ScoreFullen, ScorePoker, HoldDice, Pass, StartAccumulation, FinalizeAccumulation)
  - `createGame()` — inicialização com nomes de jogadores
  - `applyAction()` — dispatcher principal (pure function)
  - Fluxo de turno: 3 lançamentos, rotação de jogadores, fromHand tracking
  - Modo acumulação: start → hold/roll → finalize (soma progressiva)
  - Detecção de fim de jogo (4 linhas fechadas)
- `test/engine/game_engine_test.dart` — 27 testes unitários, todos a passar

### [FEATURE] Valid Actions Helper
- `getValidActions(GameState)` → `ValidActions` — calcula todas as acções legais para o estado corrente
- `ValidActions` class with: figureScoring, specialInFigure, sequences, fullens, pokers, canHold, canPass, accumulations, canFinalize
- `toList()` helper para flat list de acções concretas
- Ponte engine↔UI: a UI não precisa de duplicar lógica de validação
- 16 testes unitários para getValidActions

### [INFRA] Totais
- **92 testes unitários** (49 scoring + 27 game engine + 16 getValidActions) — todos a passar
- Cobertura: criação de jogo, scoring normal, scoring especial, hold/pass, acumulação, game over, rotação de turnos, fromHand, acções válidas
- Test cases expandidos com exemplos de Poker/Royal Poker.

## Iteração 2 — Flutter UI MVP (16 de Abril de 2026)

### [INFRA] Flutter SDK
- Instalado Git 2.53.0 via `winget install Git.Git`
- Clonado Flutter SDK 3.41.6 (stable) para `C:\flutter`
- Convertido projecto de Dart puro para Flutter (pubspec.yaml actualizado)
- Plataforma web activada (`flutter create . --platforms web`)
- Web build release funcional

### [FEATURE] Game Controller (`lib/ui/game_controller.dart`)
- `GameController extends ChangeNotifier` — ponte entre engine puro e UI Flutter
- Expõe getters para estado do jogo, dados, acções válidas
- Métodos de acção: scoreFigure, scoreSequence, scoreFullen, scorePoker, etc.
- Selecção de dados para hold (toggleDie, rollWithHeld)
- Restart game

### [FEATURE] Dice Area (`lib/ui/widgets/dice_area.dart`)
- Widget de 5 dados com tap-to-select para hold
- Indicação visual: selected (primário), held (cinzento), normal
- Mostra roll index e "from hand" status

### [FEATURE] Scorecard Table (`lib/ui/widgets/scorecard_table.dart`)
- DataTable com 5 figure lines + 3 special lines
- Colunas com mínimos indicados (≥7, ≥6, etc.)
- Linhas fechadas marcadas com lineThrough + cor
- PlayerTabs para alternar entre score cards dos jogadores

### [FEATURE] Action Panel (`lib/ui/widgets/action_panel.dart`)
- Botões dinâmicos gerados a partir de `getValidActions`
- Categorias: Hold & Roll, Pass, Figure scoring, Specials, Sequences, Fullens, Pokers, Accumulation
- Game over → botão "New Game"

### [FEATURE] Game Screen (`lib/ui/game_screen.dart`)
- Layout vertical: player banner → dice → actions → player tabs → scorecard
- Accumulation running total no AppBar
- Game over banner

### [FEATURE] Main App (`lib/main.dart`)
- Material 3 com tema verde (colorSchemeSeed: 0xFF1B5E20)
- Suporte automático para light/dark mode

### [INFRA] Totais
- **93 testes** (49 scoring + 27 game engine + 16 getValidActions + 1 widget smoke) — todos a passar

## Iteração 3 — Bug Fixes & UI Polish (16 de Abril de 2026)

### [FIX] Score perdido após fim de turno
- **Problema**: após marcar pontos e o turno terminar, a pontuação desaparecia da tabela
- **Causa raiz**: `_onStateChanged` em `GameScreen` fazia `_viewingPlayerIndex = _controller.currentPlayerIndex` em **todos** os `notifyListeners()`. Quando o turno avançava para o jogador seguinte, a scorecard mudava automaticamente para o card vazio desse jogador, dando a ilusão de pontuação perdida.
- **Correcção**: auto-follow apenas quando `currentPlayerIndex` realmente muda (tracking via `_lastKnownPlayerIndex`). Permite navegar livremente entre scorecards dos jogadores.

### [FIX] ScorecardTable always showing current player
- **Problema**: `ScorecardTable` usava `controller.currentPlayerIndex` em vez do `viewingPlayerIndex` passado via PlayerTabs
- **Correcção**: adicionado parâmetro `viewingPlayerIndex` ao widget, usado em `_buildFigureRow` e `_buildSpecialRow`

### [IMPROVE] Dice visuals — card-style design
- **v1**: Adicionado layout estilo carta de baralho com rank+suit nos cantos e símbolo central
  - A♠ (preto), K♔ (dourado), Q♕ (roxo), J♞ (azul), 10♦ (vermelho), 9♣ (verde)
  - Dark mode auto-adjust
  - Badge "HOLD" quando seleccionado
- **v2**: Removidos cantos (rank/suit), mantido apenas visual central
  - K♚ (vermelho), Q♛ (verde), J♞ (azul) — figuras centradas como o Ace
  - 9♣ mudado de verde para preto
- **v3**: Removido mirror/espelho dos face cards (K/Q/J), agora mostram apenas figura centrada (como Ace)
  - 9 = 9 clubes (pips pretos), 10 = 10 diamantes (pips vermelhos) — layout clássico de cartas

### [BUG KNOWN] Modo de Acumulação
- Funcionalidade de acumulação (Variante 2) não está a funcionar correctamente quando testada no browser
- **Próximo passo**: rever lógica em `_applyStartAccumulation`, `_applyFinalizeAccumulation`, e `_applyHoldDice` (modo acumulação). Rever `getValidActions` para estados de acumulação. Adicionar testes específicos.

### [INFRA] Totais
- **93 testes** — todos a passar
- Web build funcional com novo design de dados
- Web build release funcional

### [FEATURE] Projecto Dart criado
- `pubspec.yaml` — pacote Dart puro (sem Flutter por agora), Dart SDK ^3.0.0
- `analysis_options.yaml` — lints recomendados
- `lib/Dice Poker.dart` — barrel file de exportação

### [FEATURE] Data models implementados (`lib/engine/models.dart`)
- Enums: `DieFace`, `FigureLine`, `SpecialLine`
- Extensions: `dieFace`, `multiplier`, `weight`, `fromDieFace`
- Sealed class `SpecialCombination` com subclasses: `FiveOfAKind`, `FiveNines`, `MinStraight`, `MaxStraight`, `FullHouse`, `Poker`, `RoyalPoker`
- Data classes: `Die`, `SpecialEntry`, `ScoreCard`, `Player`
- ScoreCard helpers: `nextOpenColumn`, `filledColumns`, `isLineComplete`, `rawTotal`

### [FEATURE] Scoring engine implementado (`lib/engine/scoring.dart`)
- `calculateFigurePoints()` — cálculo de pontos para linhas de figuras (§2.1)
- `detectSpecialCombinations()` — detecção de todas as combinações especiais (§2.3–§2.10)
- `canScoreInLine()` — validação de mínimo por coluna (§2.2)
- `calculateLineScore()` — pontuação final por linha com bónus de fecho (§3)
- `calculateTotalScore()` — grand total de um jogador (§5.4)
- `isGameOver()` — condição de fim de jogo (§5.3)

### [FEATURE] Testes unitários (`test/engine/scoring_test.dart`)
- 35+ testes cobrindo todos os test cases da spec §9
- Grupos: figure points, special combos, minimum thresholds, line closing, game end, model helpers, edge cases
