## snake-tui

A text-based snake game

```text
  score:   0   hiscore:   0
┌─────────────────────────────────────────┐
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . o 0 . . . . @ . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
│ . . . . . . . . . . . . . . . . . . . . │
└─────────────────────────────────────────┘
  move: w a s d   exit: esc
```

#

### Play

To play without cloning, run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sejjy/snake-tui/main/snake.bash)
```

Otherwise, clone the repository:

```bash
git clone https://github.com/sejjy/snake-tui.git
cd snake-tui
```

and run the Bash version:

```bash
./snake.bash
```

or compile and run the C version:

```bash
make
```
