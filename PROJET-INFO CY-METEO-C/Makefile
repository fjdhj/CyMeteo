# Précise les repertoire dans lesquels chercher
vpath %.c src
vpath %.h include

all: exec

# Compilation Liste Chainee
listechainee.o: listechainee.c listechainee.h 
	gcc -c $< -o $@

# Compilation ABR
ABR.o: ABR.c ABR.h
	gcc -c $< -o $@

# Compilation AVL
AVL.o: AVL.c AVL.h
	gcc -c $< -o $@



exec: listechainee.o AVL.o ABR.o
	gcc $^ -o $@


# Supprime tous les fichiers objects