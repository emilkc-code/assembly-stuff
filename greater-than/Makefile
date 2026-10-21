NAME = greater-than

$(NAME): $(NAME).o
	ld $(NAME).o -o $(NAME)

$(NAME).o: $(NAME).asm
	nasm -f elf64 -g -F dwarf $(NAME).asm -o $(NAME).o

run: $(NAME)
	./$(NAME)

clean:
	rm -f $(NAME) $(NAME).o

.PHONY: run clean
