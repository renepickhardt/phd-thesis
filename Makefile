FILENAME = phdRenePickhardt

all: clean bibtex dvips view

build: clean all glossfull dvips
 
latex:
	latex $(FILENAME)

bibtex: latex
	bibtex ${FILENAME}
	latex $(FILENAME)
	latex $(FILENAME)

index: latex
	makeindex ${FILENAME}
	latex $(FILENAME)

gloss: latex
	glosstex ${FILENAME} ${FILENAME}.gdf
	makeindex ${FILENAME}.gxs -o ${FILENAME}.glx -s glosstex.ist
	latex $(FILENAME)

glossfull: latex gloss
	glosstex ${FILENAME} ${FILENAME}.gdf
	makeindex ${FILENAME}.gxs -o ${FILENAME}.glx -s glosstex.ist
	latex $(FILENAME)
	latex $(FILENAME)
	glosstex ${FILENAME} ${FILENAME}.gdf
	makeindex ${FILENAME}.gxs -o ${FILENAME}.glx -s glosstex.ist
	latex $(FILENAME)
	latex $(FILENAME)
	glosstex ${FILENAME} ${FILENAME}.gdf
	makeindex ${FILENAME}.gxs -o ${FILENAME}.glx -s glosstex.ist
	latex $(FILENAME)

dvips:
	dvips ${FILENAME}.dvi
	dvipdf ${FILENAME}.dvi

view:
	evince ${FILENAME}.pdf &


clean:
	rm -f *.aux *.bbl *.blg *.glx *.gxg *.gxs *.ilg *.ind *.lof *.log *.lot *.out *.pdf *.toc *.idx

cleanbck:
	rm *~ *.backup
