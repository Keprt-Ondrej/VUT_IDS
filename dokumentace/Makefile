PROJEKT = xkeprt03_xdreng01

all:
	pdflatex $(PROJEKT).tex

pack:
	zip $(PROJEKT).zip $(PROJEKT).pdf *.drawio

clean:
	rm -f *.aux *.fdb_latexmk *.fls *.log *.gz $(PROJEKT).pdf *.zip *.dvi *.ps *.out

