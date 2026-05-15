**Brick Breaker Game – 8086 Assembly Language**
A classic Brick Breaker game developed in 8086 Assembly Language using x86 DOS interrupts and VGA Mode 13h graphics.
The game features multiple levels, colorful bricks, score saving, bonus power-ups, mouse & keyboard controls, pause functionality, and high-score management.

**🎮 Features**
🧱 Classic Brick Breaker gameplay

🎨 VGA Mode 13h graphics

🕹️ Keyboard and mouse paddle controls

📈 Multiple difficulty levels

❤️ Lives system

**⭐ Bonus power-ups:**

Slow Ball

Extra Life

Wide Paddle

💾 High score saving system

📄 Score log stored in text file

⏸️ Pause/Resume functionality

🏆 Win and Game Over screens

🔊 Sound effects using BIOS/DOS interrupts

**📂 Files**
Project.asm → Main source code

SCORES.DAT → Binary high-score storage

SCORES.TXT → Readable score history log

**🛠️ Technologies Used**
8086 Assembly Language

MASM / TASM

DOS Interrupts

VGA Mode 13h

x86 Real Mode Programming

**🎯 Controls**
Key	Action
A / Left Arrow	Move paddle left
D / Right Arrow	Move paddle right
Mouse	Paddle movement
P	Pause / Resume
Enter	Select option
Backspace	Return
Esc	Exit to menu
**🧱 Levels**
**Level 1**
3 rows of bricks

Standard speed

Wide paddle

**Level 2**
5 rows of bricks

Faster gameplay

Smaller paddle

**Level 3**
6 rows of bricks

Hard bricks requiring multiple hits

Fastest gameplay

**⚡ Power-Ups**
Power-Up	Effect
S	Slows down the ball
L	Adds one extra life
W	Increases paddle width
💾 High Score System
The game automatically:

**Saves top scores in SCORES.DAT

Appends readable score logs in SCORES.TXT**

**▶️ How to Run**
Using DOSBox
Install DOSBox

Mount your project folder:

mount c c:\your-folder
c:
Assemble the code:

tasm Project.asm
tlink Project.obj
Run the game:

p5.exe
**🧠 Concepts Used**
Graphics programming in Assembly

BIOS and DOS interrupts

Collision detection

File handling

Game loops

Keyboard & mouse interrupts

Memory management

Real-time rendering

**📸 Gameplay Overview**
The player controls a paddle to bounce the ball and break all bricks on the screen.
Completing all bricks advances the player to the next level. Missing the ball reduces lives.
The game ends when all lives are lost or all levels are completed.

