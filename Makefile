all: 
	flex Toy.l
	bison	-d Toy.y -v
	gcc	-g3 -o example	Toy.tab.c	lex.yy.c	-lm
	./example $<
