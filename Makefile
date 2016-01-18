CC = i686-elf-gcc

CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Werror

LDFLAGS = 

SRC = boot/boot.s boot/kernel.s

OBJ = $(SRC:.s=.o)

NAME = os

all: $(NAME)

$(NAME): $(OBJ)
	cat $^ > iso/os.img

%.o: %.s
	nasm -f bin -o $@ $<

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

.PHONY: all
