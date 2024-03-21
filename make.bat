cd Demo/

rgbasm -o ./debug/game.o -Weverything game.asm
rgblink -o ./debug/game.gb -d -m ./debug/game.map -n ./debug/game.sym -t ./debug/game.o
rgbfix -i "DEMO" -j -k "CO" -l 0x33 -n 0x00 -p 0xFF -v ./debug/game.gb
