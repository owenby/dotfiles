OBJS = main.cpp

CC = g++

#-w suppresses warnings
COMPILER_FLAGS = -w -std=c++11 -Wall -Wextra -pedantic -pedantic-errors

LINKER_FLAGS = -framework OpenGL

OBJ_NAME = a.out

all : $(OBJS)
	$(CC) $(COMPILER_FLAGS) $(LINKER_FLAGS) $(OBJS) -o $(OBJ_NAME) && ./$(OBJ_NAME)
