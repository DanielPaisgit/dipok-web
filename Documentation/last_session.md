# Dice Poker — Last Session Context

> **Objectivo deste ficheiro**: Conter contexto suficiente para que outro AI agent possa continuar a conversa sem perda de informação. Actualizar no final de cada sessão.

---

## Sessão: 12 de Maio de 2026 (tarde)

### O que foi feito
- Implementados 5 achievements anteriormente pendentes (invictus, clutchScorer, strategist, survivor→Última Oportunidade, chameleon)
- Tracking de score snapshots adicionado ao game_screen.dart
- Ecrã About criado (about_screen.dart) com mailto feedback e link fonte regras
- Botão About (info_outline) adicionado ao AppBar do SetupScreen
- url_launcher ^6.3.0 adicionado ao pubspec.yaml
- Regras in-app (7 ficheiros .md) corrigidas: tabelas simplificadas + Pilo→Noves
- Build web compilado com sucesso

### Estado no fim da sessão
- Todos os 5 achievements implementados e activos (implemented: true)
- About screen acessível via ícone info_outline no SetupScreen AppBar
- **Email de feedback**: `feedback@dicepoker.app` — PLACEHOLDER, actualizar antes de publicar
- Build feito, **push para dipok-web pendente** (ver Próximos Passos)

### Próximos passos imediatos
1. **Push web build**: copiar `build/web/*` → root, commit, push origin main → Render auto-deploy
2. **T4**: Android release build (key.properties + signingConfig + `flutter build appbundle --release`)
3. **Actualizar email** em `lib/ui/about_screen.dart` (constante `_feedbackEmail`)

---

## Sessão: 12 de Maio de 2026 (manhã)

### O que foi feito
- Revisão do estado do projecto após pausa desde 24 Abril
- Revisão e correcção da ordem de trabalhos (9 tarefas — ver PENDING_DECISIONS.md secção 6)
- Decisido usar Google Play Internal Testing para beta (não APK sideloading)
- **Tomadas todas as decisões de produto (T1 completa ✅)**

### Decisões tomadas

| Área | Decisão |
|------|---------|
| Free tier | Jogo 1v1, todos os idiomas, perfil Balanced, primeiros 5 achievements |
| Achievements free | firstWin, hatTrick, aiSlayer, piladaFromHand, perfectStraight |
| Achievements premium | Restantes 35 — visíveis mas bloqueados com cadeado |
| Preço | Compra única €4,99 que desbloqueia tudo |
| Perfis AI free | Só Balanced; Aggressive, Cautious, Dreamer são premium |
| Multiplayer scope | Sala com código + lista de amigos + matchmaking aleatório |
| Autenticação | Email/password + login social (Google e Apple) |
| Linguagem | "Pilo/Pilada" substituído por "Nove/Noves" em todo o projecto |

### Alterações de código feitas
- `app_strings.dart` — achievement title PT `'Pilada de Mão'` → `'Cinco Noves!'`
- `achievements_service.dart` — fallback title corrigido
- `models.dart` — comentário `nine` actualizado
- `project_description.md`, `user_manual.md` — "pilo/pilada" → "nove/noves"
- `game_rules_it.md`, `game_rules_fr.md` — tabelas e secções corrigidas

### Estado no fim da sessão
- **T1 completa** — todas as decisões de produto tomadas
- **T2, T3 prontas para avançar** (sem dependências)

### Próximos passos imediatos
- **T2**: Web deploy no Render (`flutter build web` → repositório → Render static site)
- **T3**: Abrir conta Google Play Developer (25 USD — play.google.com/console)
- T2 e T3 podem correr em paralelo

### Decisões ainda em aberto (menores, não bloqueantes)
- Preços por mercado: aceitar conversão automática Google ou definir manualmente?
- Web: domínio personalizado ou subdomínio Render?
- Play Store: nome final da app, política de privacidade

---

## Sessão: 24 de Abril de 2026


### O que foi pedido nesta sessão
1. Criar documento de regras do jogo (`game_rules.md`) — PT-PT
2. Criar user manual (`user_manual.md`) — PT-PT
3. Internacionalização completa para 7 idiomas: PT-PT, PT-BR, ES, FR, DE, IT, EN
4. Menu de selecção de idioma (separado do setup de jogadores)

### O que foi feito

#### 1. Documentação PT-PT criada
- `Documentation/game_rules.md` — referência rápida + regras completas em PT-PT
- `Documentation/user_manual.md` — manual de utilizador completo em PT-PT

#### 2. i18n expandida para 7 idiomas
- `lib/ui/i18n/app_strings.dart` reescrito:
  - Novo enum `AppLang { en, ptPT, ptBR, es, fr, de, it }`
  - Todos os strings de UI traduzidos nos 7 idiomas com `switch` expressions
  - Títulos e descrições de conquistas (40 achievements) totalmente localizados
  - Novos strings: `achievements`, `achievementsUnlocked`, `pendingSuffix`, `close`, `language`, `languageScreenTitle`, `languageSystemDefault`

#### 3. Novo serviço de locale
- `lib/ui/services/locale_service.dart` — persiste/restaura locale via `shared_preferences` (chave `app.locale.v1`)

#### 4. Selector de idioma
- `lib/ui/language_screen.dart` — ecrã dedicado com lista de 7 idiomas (flag + nome nativo + checkmark)
- `LocaleController` InheritedWidget em `main.dart` — expõe `setLocale(Locale?)` pelo widget tree
- `Dice PokerApp` tornado stateful; carrega locale guardado no `initState`
- `supportedLocales` expandidos: en, pt-PT, pt-BR, pt, es, fr, de, it
- Botão 🌐 no AppBar do `SetupScreen` → abre `LanguageScreen`

#### 5. Setup screen actualizado
- Achievements dialog usa strings localizados: `strings.achievements`, `strings.achievementsUnlocked`, `strings.achievementTitle(id)`, `strings.achievementDesc(id)`, `strings.pendingSuffix`, `strings.close`
- Botão Achievements usa `strings.achievements` (em vez de `const Text('Achievements')`)

#### 6. Documentação traduzida (×6 idiomas)
- `game_rules_pt_br.md`, `game_rules_es.md`, `game_rules_fr.md`, `game_rules_de.md`, `game_rules_it.md`
- `user_manual_pt_br.md`, `user_manual_es.md`, `user_manual_fr.md`, `user_manual_de.md`, `user_manual_it.md`

### Validação
- `flutter analyze`: 0 erros (apenas avisos pré-existentes)
- `flutter test`: 117/117 a passar

### Estado actual do projecto
- **Fase**: Pronto para deploy
- **Idiomas**: 7 (EN, PT-PT, PT-BR, ES, FR, DE, IT)
- **Testes**: 117 total, todos a passar

### Próximos passos (por ordem de prioridade)
1. **Tomar decisões de produto** — ver `Documentation/PENDING_DECISIONS.md`
2. **Publicação web** — deploy no Render (static site, `build/web`)
3. **Android** — Play Store (25 USD conta Google Play Developer)
4. **Multiplayer** — Supabase Realtime + turnos assíncronos
5. **Monetização** — `in_app_purchase`, freemium feature gating
6. **iOS** — adiar até haver receita do Android

### Decisões de produto em aberto
Ver `Documentation/PENDING_DECISIONS.md` para lista completa. As mais urgentes:
- Feature gating: o que fica free vs premium
- Autenticação multiplayer: anónima vs conta
- Pack único vs granular (preços)

---

## Sessão: 23 de Abril de 2026

### O que foi pedido nesta sessão
1. Acrescentar novas tarefas à lista de prioridades (regras, manual, testes de exaustão, estatísticas)
2. Implementar **Setup screen** com configuração de jogadores/AI
3. Explicar e implementar **persistência**
4. Prosseguir de forma autónoma e manter documentação actualizada

### O que foi feito
1. **Lista de prioridades actualizada e reordenada**
  - Incluídos: testes de exaustão, estatísticas de simulação, regras do jogo, user manual
2. **Setup screen implementado**
  - Número de jogadores: 1-4
  - Nome por jogador
  - Toggle humano/AI por jogador
  - Perfil AI por jogador (Balanced/Aggressive/Cautious)
  - `main.dart` arranca agora no setup
3. **Persistência de configuração do setup**
  - Guarda/restaura: player count, nomes, AI on/off, perfis
4. **Persistência de partida (save/resume)**
  - Snapshot local do `GameState` + `aiProfiles` via `shared_preferences`
  - Botão "Continue Saved Game" no setup quando existe partida guardada
  - Auto-save durante jogo e limpeza automática ao terminar jogo
5. **Validação**
  - Testes: 112/112 a passar após alterações
6. **Responsive layout concluído**
  - `GameScreen` com breakpoints para mobile (stack vertical) e desktop/tablet largo (duas colunas)
  - `SetupScreen` com cards em grelha para ecrãs largos e lista única em mobile
  - Melhor comportamento de espaço para scorecard, acções e configuração
7. **i18n EN/PT concluído (base UI)**
  - `MaterialApp` com `supportedLocales` EN/PT e delegates de localização
  - Camada de strings localizada em `lib/ui/i18n/app_strings.dart`
  - Textos principais localizados em setup, game screen, action panel e scorecard
  - Selecção automática por locale do dispositivo
8. **Polish visual concluído (scorecard totals)**
  - Barra de totais sempre visível na scorecard
  - Totais por linha (A/K/Q/J/10), especiais (Seq/Full/Poker) e total geral
  - Melhor legibilidade com chips e destaque para total geral
9. **Achievements implementado (base + milestones cumulativos)**
  - Novo serviço: `lib/ui/services/achievements_service.dart`
  - Mantidos os achievements sugeridos + novos milestones de poker/seq/full
  - Novo achievement: 5 iguais nas 6 faces ao longo do tempo
  - Contadores cumulativos:
    - Poker total: 10/30/50/100/200/500
    - Sequencias de mao: 100/200/500/1000/3000/10000
    - Full house de mao: 100/200/500/1000/3000/10000
  - Integração no fluxo de jogo (processamento no game over)
  - UI no setup: botão/lista de Achievements com estado desbloqueado/progresso
  - Alguns achievements avançados marcados como **em aberto** para iterações futuras
10. **Limpeza de legado concluída**
  - `lib/ui/widgets/dice_area.dart` removido do repositório
  - Código ativo já usava exclusivamente `dice_3d.dart`
  - Validação pós-limpeza: 115/115 testes a passar
11. **Testes de exaustão + estatísticas implementados**
   - Novo runner: `tool/stress_simulation.dart`
   - Simulação engine-only (sem UI) com parâmetros:
     - `--games` (default 1000)
     - `--seed` (reprodutibilidade)
     - `--max-moves` (safety cap)
   - Outputs automáticos por corrida em `output/simulations/`:
     - `<run_id>.json` (detalhado)
     - `<run_id>_summary.csv` (resumo por perfil)
   - Métricas incluídas:
     - vitórias por perfil e por posição
     - médias/mediana/desvio por perfil
     - frequência de poker/seq/full e versões de mão
     - performance (ms/jogo, moves/jogo) e integridade (erros)
   - Smoke run validada (50 jogos): ~6.18 ms/jogo, 0 erros, JSON+CSV gerados
12. **Novo perfil AI: Dreamer (Sonhador)**
   - Adicionado ao enum `AiProfile`
   - Comportamento: joga prioritariamente para poker; aceita resultados não-poker quando surgem de mão
   - Integrado na UI (setup/i18n) e no simulador
13. **Simulações de comparação executadas**
   - Modos novos no runner:
     - `--mode mirror --profile <perfil>`
     - `--mode mixed-fair`
   - Bateria corrida (1000 jogos cada):
     - mirror: balanced, aggressive, cautious, dreamer
     - mixed-fair: balanced+aggressive+cautious+dreamer com rotação de seats
   - Resultado principal: no mixed-fair, Dreamer tem win rate muito inferior aos restantes perfis
14. **Validação estatística ampliada (100000 jogos)**
   - Corrida adicional: `--mode mixed-fair --games 100000`
   - Run IDs registados: `20260423_004229` e `20260423_004359`
   - Integridade: 100000/100000 jogos completos, 0 erros
   - Resultados por perfil (win rate):
     - aggressive: 34.911%
     - balanced: 29.248%
     - cautious: 26.918%
     - dreamer: 8.923%
   - Conclusão: Dreamer mantém identidade temática, mas está claramente abaixo em competitividade mista

### Estado actual do projecto
- **Fase**: Desenvolvimento com onboarding completo (setup) e retoma de sessão (save/resume)
- **Persistência activa**:
  - Setup config (última configuração usada)
  - Match snapshot (retomar jogo em curso)
- **Testes**: 117 total, todos a passar

15. **Fix: dados bloqueados persistem entre lançamentos**
   - `_selectedDice.clear()` em `_performActionWithRoll` só é chamado quando a ação não é `HoldDice` ou quando o jogador muda
   - Antes: bloqueavar dados → lançava → seleção desaparecia
   - Depois: dados bloqueados mantêm-se visualmente selecionados no lançamento seguinte

### Próximos passos (por ordem de prioridade)
1. **Regras do jogo** — documento dedicado e limpo para jogadores (versão curta + versão completa)
2. **User manual** — manual de utilização (setup, turnos, scoring, UI e resolução de problemas comuns)
3. **Publicação web** — deploy em GitHub Pages ou similar para partilhar

---

## Sessão: 18 de Abril de 2026

### Quem é o utilizador
- Nome: Daniel Pais
- Localização dos ficheiros: `c:\Users\Daniel.Pais\Downloads\Dice Poker\`
- Ambiente: Windows, VS Code, múltiplos projectos abertos no workspace

### O que foi pedido nesta sessão
1. Bugs: poker com 4 nines não detectado; HOLD badge persistia após scoring
2. Linhas especiais (seq, full, poker) devem fechar como figure lines (máx 5, contam para game over)
3. Remover títulos "C1, C2..." das colunas
4. Adicionar som real de dados
5. Testes de regressão para todos os bugs
6. Actualizar documentação e próximos passos

### O que foi feito
1. **Fix poker 4 nines**: Removida exclusão de nines em `detectSpecialCombinations`
2. **Fix HOLD badge**: `_selectedDice.clear()` em todas as acções do controller
3. **Linhas especiais fecham**:
   - `closedSpecialLines` + `closedSpecialBy` no `GameState`
   - `getValidActions` bloqueia scoring em linhas fechadas
   - `isGameOver` conta figure + special (4 de 8)
   - UI mostra riscado + fundo vermelho + entradas em colunas
4. **Títulos simplificados**: "≥7", "≥6", etc. em vez de "C1 (≥7)"
5. **Som real** via `audioplayers`:
   - 3 WAVs gerados proceduralmente (`tool/generate_sounds.dart`)
   - `DiceSoundService` com `AudioPlayer` + haptic
   - `onLanded` callback em `Dice3DRow`, `onScored` em `ActionPanel`
6. **6 testes de regressão** adicionados
7. **Documentação**: changelog (Iteração 7), last_session actualizado

### Estado actual do projecto
- **Fase**: Desenvolvimento — jogo completo end-to-end (scoring, acumulação, dados animados, som, game over, AI, linhas especiais fecham)
- **Código**: Flutter 3.41.6, Material 3, web + mobile target
- **Spec**: `Documentation/game_specification.md` — fonte de verdade
- **Ficheiros de código (engine)**:
  - `lib/engine/constants.dart` — constantes do jogo (8 linhas totais, 4 para game over)
  - `lib/engine/models.dart` — enums, classes, tipos (inclui `SpecialLine`, `ContinueAccumulation`)
  - `lib/engine/scoring.dart` — funções de scoring (puras) + `calculateTotalScore()` + `isGameOver()`
  - `lib/engine/game_engine.dart` — estado do jogo, acções, turnos, acumulação, `closedSpecialLines`
  - `lib/engine/ai_profiles.dart` — lógica de decisão AI (3 perfis)
- **Ficheiros de código (UI)**:
  - `lib/main.dart` — entry point, Dice PokerApp
  - `lib/ui/game_controller.dart` — ChangeNotifier bridge (isRolling, selectedDice, AI scheduling)
  - `lib/ui/game_screen.dart` — ecrã principal (Dice3DRow, game-over dialog, AI indicators, som)
  - `lib/ui/widgets/dice_3d.dart` — scatter+settle animação + `onLanded` callback
  - `lib/ui/widgets/dice_area.dart` — widget antigo (não usado, mantido)
  - `lib/ui/widgets/scorecard_table.dart` — tabela de pontuação (figure + special lines com closing)
  - `lib/ui/widgets/action_panel.dart` — painel de acções (com `onScored` callback)
  - `lib/ui/services/dice_sound.dart` — `audioplayers` + haptic feedback
- **Assets**: `assets/audio/dice_roll.wav`, `dice_land.wav`, `score.wav`
- **Tools**: `tool/generate_sounds.dart` — gerador procedural de WAVs
- **Testes**: 112 total (49 scoring + 54 game engine + 8 AI + 1 widget smoke), todos a passar
- **Web build**: `flutter run -d chrome` funcional

### Próximos passos (por ordem de prioridade)
1. **Setup screen** — escolher nomes, número de jogadores (1-4), e quais são AI (com perfil)
2. **Persistência** — guardar estado do jogo (local storage / Hive) + retomar partida
3. **Responsive layout** — adaptar para ecrãs pequenos (mobile) vs grandes (web/desktop)
4. **i18n** — internacionalização EN + PT
5. **Polish visual** — melhorar scorecard (totais por linha, total geral visível durante jogo)
6. **Achievements** — sistema de conquistas:
  - Exemplos: "Royal Poker!", "Pilada de mão", "Fechar linha sem abrir", "5 sequências", etc.
7. **Remover** `dice_area.dart` antigo
8. **Testes de exaustão** — simular jogos em massa (ex.: 1000 jogos automáticos) para validar estabilidade e balanceamento
9. **Estatísticas da simulação** — vitórias por perfil AI, frequência de poker/full/sequências, média de pontos por jogo/jogador/perfil
10. **Regras do jogo** — documento dedicado e limpo para jogadores (versão curta + versão completa)
11. **User manual** — manual de utilização (setup, turnos, scoring, UI e resolução de problemas comuns)
12. **Publicação web** — deploy em GitHub Pages ou similar para partilhar

### Ambiente / PATH
- Flutter SDK: `C:\flutter\bin` (NÃO está no PATH do sistema)
- Git: `C:\Program Files\Git\cmd`
- **Receita de PATH** (obrigatória em cada terminal novo):
  ```powershell
  $env:Path = "C:\flutter\bin;C:\Program Files\Git\cmd;" + [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
  ```

### Referência chave
- `Documentation/game_specification.md` — especificação formal completa com data model, API, e test cases

### Questão pendente
- **C)** Ranking/prioridade de mãos para desempate — confirmar se necessário ou se o total resolve

### Compatibilidade multi-plataforma (referência futura)

| Funcionalidade | Web | Mobile (Play Store) | Desktop | Notas |
|---|---|---|---|---|
| Código actual | ✅ | ✅ | ✅ | Tudo portável, zero deps platform-specific |
| Monetização (ads) | ❌ `google_mobile_ads` não funciona em web | ✅ `google_mobile_ads` | ❌ | Estratégia diferente por plataforma |
| In-app purchases | ❌ | ✅ `in_app_purchase` | ❌ | Só mobile |
| Persistência | ✅ `shared_preferences` / `hive` | ✅ mesmos packages | ✅ | Cross-platform |
| Som real (dados) | ✅ implementado | ✅ | ✅ | `audioplayers` + WAVs |
| Responsive layout | Ecrã grande | Ecrã pequeno | Ecrã grande | `LayoutBuilder` para adaptar |

- Monetização é o único ponto que requer `kIsWeb` / `Platform.isAndroid` checks (~5-10 linhas)
- Tudo o resto (engine, UI, animações, game over) funciona identicamente em todas as plataformas
