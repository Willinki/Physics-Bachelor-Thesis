LIBS:=`root-config --libs`
INCS:=`root-config --cflags`

plotchi2: plotchi2.cpp
	g++ -Wall -o $@ $^ ${INCS} ${LIBS}
%.o: %.cpp %.h
	g++ -Wall -c -o $@ $< ${INCS}
clean:
	rm *.o
