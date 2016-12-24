hello.bin : hello.asm
	nasm -o hello.bin hello.asm
	dd if=hello.bin of=hello.img count=512 bs=1
clean:
	rm -rf *.bin *.img
