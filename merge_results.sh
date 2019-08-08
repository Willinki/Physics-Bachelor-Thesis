#!/bin/bash

#lo script ha lo scopo di prendere più simulazioni, lanciate attraverso sumbit.sh e unire i risultati in un unico file avente la stessa formattazione dei precedenti, con ovvi vantaggi di precisione.
#per essere avviato necessita come argomento il numero di simulazioni da unire

#posizione della cartella run-test, dove sono salvati i file .top delle varie simulazioni. per ora i file .top presi in considerazione sono:
#pwg-NLO-n.top dove n è il numero relativo alla n-esima simulazione
#pwgpwhgalone-output-n.top dove n è il numero relativo alla n-esima simulazione
MYDIR=/home/davidebadalotti/Tesi/
risultati=$(pwd)
merged=${risultati}/merged
mkdir -p ${merged}
#controllo che gli argomenti siano dati correttamente, deve essere presente il numero di simulazioni
if [[ $# -eq 1 ]]
then
  #creazione dei file finali -merged.top, per ora vuoti
  > ${merged}/pwg-NLO-merged.top
  > ${merged}/pwgpwhgalone-output-merged.top


  for ((ngraph=0; ngraph<70; ++ngraph)) do
    echo ${ngraph}
    #stampa il titolo del grafico sui file -merged.top
    grep "index\s\{2,3\}${ngraph}\b" ${risultati}/pwg-NLO-1.top >> ${merged}/pwg-NLO-merged.top
    grep "index\s\{2,3\}${ngraph}\b" ${risultati}/pwgpwhgalone-output-1.top >> ${merged}/pwgpwhgalone-output-merged.top
    #salva i valori del grafico della prima simulazione in file dummyNLO1  e dummyALONE1, questi file sono solo di appoggio, e verranno eliminati alla fine dello script.
    #i file dummy contengono solo i numeri di un grafico alla volta, senza titoli o righe vuote
    cat ${risultati}/pwg-NLO-1.top | sed -n "/index\s\{2,3\}${ngraph}\b/,/index\s\{2,3\}$((ngraph+1))\b/p" | sed '1d' | head -n -3 > ${risultati}/dummyNLO1.txt
    cat ${risultati}/pwgpwhgalone-output-1.top | sed -n "/index\s\{2,3\}${ngraph}\b/,/index\s\{2,3\}$((ngraph+1))\b/p" | sed '1d' | head -n -3 > ${risultati}/dummyALONE1.txt

    #ciclo effettuato sullo stesso grafico di ogni simulazione
    for ((nsim=2; nsim<$1+1; ++nsim)) do
      #creazione file dummyNLO2 e dummyALONE2, simili ai corrispondenti 1, a partire dai grafici delle altre simulazioni
      cat ${risultati}/pwg-NLO-${nsim}.top | sed -n "/index\s\{2,3\}${ngraph}\b/,/index\s\{2,3\}$((ngraph+1))\b/p" | sed '1d' | head -n -3 > ${risultati}/dummyNLO2.txt
      cat ${risultati}/pwgpwhgalone-output-${nsim}.top | sed -n "/index\s\{2,3\}${ngraph}\b/,/index\s\{2,3\}$((ngraph+1))\b/p" | sed '1d' | head -n -3 > ${risultati}/dummyALONE2.txt
      #aggiornamento del file dummyNLO1 e dummyALONE1, sostituendo alla colonna dei valori la somma fra dummy1 e dummy2 e alla colonna dell'errore la radice quadrata della somma in quadratura degli errori
      #il file dummy.txt è usato solo perchè non era possibile leggere e scrivere contemporaneamente dummyNLO1 e dummyALONE1
      paste ${risultati}/dummyNLO1.txt ${risultati}/dummyNLO2.txt | awk '{printf $1 " " $2 " ";
                                                                          printf("%.7E", $3+$7);
                                                                          printf " ";
                                                                          printf("%.7E\n", sqrt($4*$4 + $8*$8))}' > ${risultati}/dummy.txt
      mv ${risultati}/dummy.txt  ${risultati}/dummyNLO1.txt
      paste ${risultati}/dummyALONE1.txt ${risultati}/dummyALONE2.txt | awk '{printf $1 " " $2 " ";
                                                                              printf("%.7E", $3+$7);
                                                                              printf " ";
                                                                              printf("%.7E\n", sqrt($4*$4 + $8*$8))}' > ${risultati}/dummy.txt
      mv ${risultati}/dummy.txt  ${risultati}/dummyALONE1.txt

    done
    #ora si modificano dummyNLO1 e dummyALONE1 in modo da avere, nella terza colonna, la media dei valori di tutte le simulazioni, per ogni bin
    #nella quinta si ha l'errore relativo per ogni misura, cioè la radice quadrata della somma in quadratura degli errori divisa per sqrt(N)*N dove N è il numero di simulazioni (misure per ogni bin)
    #i risultati vengono aggiunti al file merged
    cat ${risultati}/dummyNLO1.txt | awk -v N=$1 '{printf " " $1 " " $2 " ";
                                                   printf ("%.7E", $3/N);
                                                   printf " ";
                                                   printf ("%.7E\n",($4)/N^1.5) }' >> ${merged}/pwg-NLO-merged.top
    cat ${risultati}/dummyALONE1.txt | awk -v N=$1 '{printf " " $1 " " $2 " ";
                                                   printf ("%.7E", $3/N);
                                                   printf " ";
                                                   printf ("%.7E\n",($4)/N^1.5) }' >> ${merged}/pwgpwhgalone-output-merged.top
    #vengono lasciate due righe di spazio fra i grafici per mantenere la formattazione
    printf "\n \n" >> ${merged}/pwg-NLO-merged.top
    printf "\n \n" >> ${merged}/pwgpwhgalone-output-merged.top

  done

  rm ${risultati}/dummyNLO1.txt
  rm ${risultati}/dummyNLO2.txt
  rm ${risultati}/dummyALONE1.txt
  rm ${risultati}/dummyALONE2.txt
else
  echo "Argomenti non corretti."
fi
