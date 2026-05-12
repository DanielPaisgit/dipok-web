# Poker de Dados — Manual de Utilizador / User Manual

> Este manual explica como usar a aplicação Poker de Dados, desde a configuração inicial até ao fim de um jogo.

---

## Índice

1. [Ecrã de Configuração (Setup)](#1-ecrã-de-configuração-setup)
2. [Retomar um Jogo Guardado](#2-retomar-um-jogo-guardado)
3. [Ecrã de Jogo](#3-ecrã-de-jogo)
4. [Como Jogar um Turno](#4-como-jogar-um-turno)
5. [Acumulação](#5-acumulação)
6. [Tabela de Pontuação (Scorecard)](#6-tabela-de-pontuação-scorecard)
7. [Fim do Jogo](#7-fim-do-jogo)
8. [Conquistas (Achievements)](#8-conquistas-achievements)
9. [Jogadores Controlados por IA](#9-jogadores-controlados-por-ia)
10. [Perguntas Frequentes](#10-perguntas-frequentes)

---

## 1. Ecrã de Configuração (Setup)

Ao abrir a aplicação, é apresentado o ecrã de configuração:

### Número de Jogadores

Selecciona de **1 a 4 jogadores** com o selector no topo.

### Configurar Cada Jogador

Para cada jogador aparece um cartão com:

- **Nome** — campo de texto editável (ex: "Ana", "Player 1").
- **Humano / IA** — toggle para definir se o jogador é controlado por humano ou por IA.
- **Perfil de IA** (quando IA está activo) — escolha o comportamento da IA:
  | Perfil | Comportamento |
  |---|---|
  | Balanced | Estratégia equilibrada entre figuras e especiais |
  | Aggressive | Prioriza especiais (sequências, fullens) |
  | Cautious | Foca em fechar linhas de figura com segurança |
  | Dreamer | Joga apenas para Poker; aceita outros resultados só se de mão |

### Iniciar o Jogo

Carrega em **"Start Game"** para iniciar com a configuração actual.

> A última configuração usada é guardada automaticamente e aparece pré-preenchida na próxima vez que abrires a app.

---

## 2. Retomar um Jogo Guardado

Se existir um jogo em curso guardado, aparece o botão **"Continue Saved Game"** no ecrã de configuração.

- Carrega no botão para retomar a partida exactamente onde ficou.
- Quando um jogo termina normalmente (ou é abandonado), o estado guardado é limpo automaticamente.

---

## 3. Ecrã de Jogo

O ecrã de jogo divide-se em três áreas principais:

```
┌─────────────────────────────────────┐
│          ÁREA DOS DADOS             │
│   (5 dados animados, clicáveis)     │
├─────────────────────────────────────┤
│          PAINEL DE ACÇÕES           │
│  (botões: Roll / Hold / Score / ...) │
├─────────────────────────────────────┤
│          SCORECARD                  │
│  (tabela de pontuação de todos)     │
└─────────────────────────────────────┘
```

Em ecrãs largos (tablet/desktop), o scorecard fica numa coluna lateral.

### Indicador de Turno

No topo do ecrã é apresentado:
- Nome do jogador actual
- Número do lançamento actual (1 de 3, 2 de 3, 3 de 3)
- Ícone de IA se o jogador actual for controlado por IA

---

## 4. Como Jogar um Turno

### Passo 1 — Lançar os dados

No início do turno (ou após marcar pontos num lançamento anterior), carrega em **"Roll"** para lançar todos os 5 dados. Os dados animam ao cair.

### Passo 2 — Depois de ver o resultado

Tens três opções:

#### Opção A: Segurar dados e relançar

1. Carrega nos dados que queres **manter** — ficam marcados com um ícone de cadeado (🔒).
2. Carrega em **"Roll"** para relançar apenas os dados não marcados.
3. Os dados segurados mantêm-se para o próximo lançamento.

> Podes mudar a selecção antes de lançar: clicar num dado marcado desmarca-o.

#### Opção B: Marcar pontos

1. No painel de acções, aparece uma lista das linhas elegíveis onde podes marcar com os dados actuais.
2. Carrega na linha pretendida (ex: "Queens — 7 pts") para registar os pontos.
3. Todos os dados são recolhidos; o próximo lançamento conta como **"de mão"**.

> Só aparecem linhas que cumpram o mínimo da coluna seguinte. Linhas fechadas ou já usadas neste turno não aparecem.

#### Opção C: Passar

Carrega em **"Pass"** para avançar para o próximo lançamento sem marcar nem segurar.

Após o **3º lançamento**, o turno termina. Se não marcaste nada nos 3 lançamentos, a vez passa ao jogador seguinte sem penalização.

---

## 5. Acumulação

A acumulação é activada **automaticamente** quando, ao marcar numa linha de figura, todos os 5 dados correspondem à figura ou são 9s.

Quando acontece:
- O jogo entra no **Modo Acumulação** para essa linha.
- O ecrã indica a linha alvo e o total acumulado até agora.

Durante a acumulação:
- **Continue** — relança todos os 5 dados e adiciona os pontos de figura ao acumulado.
- **Segurar + Relançar** — segura alguns dados e relança os restantes; os pontos são adicionados ao acumulado.
- **Finalizar** — regista o total acumulado na coluna (se ≥ mínimo). Feito automaticamente ao premir "Pass".

> Durante acumulação não é possível marcar noutras linhas. Combinações especiais (sequências, poker, etc.) detectadas são ignoradas.

---

## 6. Tabela de Pontuação (Scorecard)

A scorecard mostra a pontuação de todos os jogadores em tempo real.

### Linhas de Figura (A, K, Q, J, 10)

Cada linha mostra 5 colunas. Para cada jogador:
- Colunas preenchidas mostram o valor registado.
- A coluna seguinte (por preencher) é destacada.
- Quando uma linha está fechada, aparece riscada com fundo vermelho.

### Linhas Especiais

- **Seq** — lista de sequências marcadas (cada valor individualmente).
- **Full** — lista de fullens marcados.
- **Poker** — lista de pokers marcados.

### Barra de Totais

No fundo da scorecard há uma barra de totais sempre visível:
- Total por linha de figura (valor bruto acumulado até agora; o multiplicador é aplicado no fim).
- Total de especiais.
- **Total geral** (soma de tudo).

> Os totais das linhas de figura são parciais durante o jogo. O multiplicador (e eventual duplicação por bónus de fecho) só são aplicados quando a linha fecha.

---

## 7. Fim do Jogo

O jogo termina quando **4 das 5 linhas de figura** estão fechadas (falta apenas 1 por fechar).

É apresentado o **ecrã de fim de jogo** com:
- Pontuação final de cada jogador (com detalhes por linha).
- Destaque do vencedor.
- Botões para **jogar novamente** (mesma configuração) ou **voltar ao setup**.

---

## 8. Conquistas (Achievements)

No ecrã de setup, o botão **"Achievements"** abre a lista de conquistas desbloqueáveis:

| Conquista | Condição |
|---|---|
| Royal Poker! | Poker Real (4 Ases + Rei) de mão |
| Cinco Noves de mão | 5 noves no 1º lançamento |
| Muro! | Fechar uma linha sem que outro jogador a tenha aberto |
| Sequência perfeita | Sequência máxima de mão |
| Primeiro Poker | Primeiro poker conseguido |
| ... | e muitas mais |

Conquistas com **progresso cumulativo** (ex: "50 pokers totais") mostram a barra de progresso actual.

As conquistas são guardadas e persistem entre sessões.

---

## 9. Jogadores Controlados por IA

Quando é a vez de um jogador IA:
- Um ícone de robô é mostrado junto ao nome do jogador.
- A IA joga automaticamente após um breve atraso (para que possas acompanhar as acções).
- Não precisas de fazer nada — a IA executa as suas acções até ao fim do turno.

---

## 10. Perguntas Frequentes

**Posso marcar numa linha especial e também numa linha de figura no mesmo turno?**
Sim. Podes marcar em linhas diferentes ao longo do mesmo turno, incluindo misturar figuras e especiais. Não podes marcar **duas vezes na mesma linha** no mesmo turno.

**O que acontece se não atingir o mínimo em nenhuma linha?**
Podes segurar dados e tentar nos lançamentos seguintes, ou passar. Se chegarmos ao 3º lançamento sem marcar nada, a vez perde-se (sem penalização).

**Posso marcar numa linha já fechada?**
Não. Uma linha fechada está bloqueada para todos os jogadores.

**O que é "de mão" exactamente?**
É qualquer lançamento em que os 5 dados foram lançados sem nenhum segurado. Acontece sempre no 1º lançamento do turno, e também no 2º ou 3º se o jogador marcou pontos no lançamento anterior (recolheu todos os dados). Nestas condições, combinações especiais valem o dobro.

**Posso sair a meio do jogo e retomar mais tarde?**
Sim. O jogo é guardado automaticamente a cada acção. Quando abrires a app novamente, o botão "Continue Saved Game" no ecrã de setup permite retomar.

**O Poker só conta de mão — e os outros pokers de 4 iguais?**
Exacto. Se saírem 4 iguais mas não for de mão, não há pontuação especial de Poker — o resultado é tratado como um lançamento normal e pode ser marcado na linha de figura correspondente.

**Posso jogar sozinho?**
Sim. Podes configurar 1 jogador humano e 1–3 jogadores IA.

---

*Poker de Dados v1.0 — Boa sorte! 🎲*

