# Précise les repertoire dans lesquels chercher
vpath
vpath %.c src
vpath %.h include

all: exec clean

# Compilation Liste Chainee
listechainee.o: listechainee.c listechainee.h 
	gcc -c $< -o $@

# Compilation ABR
ABR.o: ABR.c ABR.h
	gcc -c $< -o $@

# Compilation AVL
AVL.o: AVL.c AVL.h
	gcc -c $< -o $@

main.o: main.c masterlib.h
	gcc -c $< -o $@

exec: listechainee.o AVL.o ABR.o main.o
	gcc $^ -o $@


# Supprime tous les fichiers objects
clean:
	rm -f *.o