#!/bin/bash
#lo script ha lo scopo di calcolare la matrice di covarianza delle distribuzioni PDF di alcune grandezze
#in particolare VM E (F-B)/VM

START=$(pwd)
#-----------------------------------
#    DEFINIZIONE PARAMETRI
#-----------------------------------
SCRIPTS=/home/davidebadalotti/Tesi/dati_scripts
SDIR=/home/davidebadalotti/RUNS/run2-meanstdPDF-medium-19.08.03
FILE=pwg-NLO-500.top
#DIR=$SDIR/AFBPDF-$FILE
DIR=$SDIR/VMPDF-$FILE
LIMINF=0.80000000E+02
LIMSUP=0.10000000E+03
NTPDF=100
#-----------------------------------
#    FINE PARAMETRI
#-----------------------------------
NBINS=$( awk -v L=$LIMSUP -v l=$LIMINF 'BEGIN {printf (L-l)}')

echo "ESTRAZIONE GRAFICI..."
/home/davidebadalotti/Tesi/dati_scripts/extract_templates.sh VMPDF $SDIR/$FILE 2> /dev/null
#/home/davidebadalotti/Tesi/dati_scripts/extract_templates.sh AFBPDF $SDIR/$FILE 2> /dev/null
cd $DIR
echo "TAGLIO GRAFICI..."
for file in $(ls -1); do
  sed -i --silent "/$LIMINF/,/$LIMSUP/p" $file
  sed -i "1d" $file
done

#calcolo delle medie fra PDF con rispettive deviazioni standard, per facilitare dopo
#dummy.txt è il file che contiene la somma dei quadrati e dei bin, necessari per calcolare
# media e deviazione standard dei bin
echo > /tmp/dummy.txt
echo > /tmp/total.txt
echo > /tmp/meanSTD.txt
TFILE=$(ls -1 *PDF1-* | sed --silent "1p")
cat $TFILE > /tmp/total.txt
awk '{ printf "%.8f  %.8f\n", $3, $3^2 }' /tmp/total.txt > /tmp/dummy.txt

for ((npdf=2; npdf<=NTPDF; ++npdf)); do
  TFILE=$(ls -1 *PDF$npdf-* | sed --silent "1p")
  paste /tmp/dummy.txt $TFILE > /tmp/total.txt
  awk '{ printf "%.8f  %.8f\n", $1+$5, $2+$5^2 }' /tmp/total.txt > /tmp/dummy.txt
done

#/tmp/meanSTD.txt è il file contenente media e deviazione standard bin per bin per tutte le PDF
#viene calcolato preventivamente per evitare ripetizioni inutili
awk -v N="$NTPDF" '{ printf "%.8f  %.8f\n", $1/N, sqrt( ($2 - ($1^2)/N)/N ) }' /tmp/dummy.txt > /tmp/meanSTD.txt
#--------------------------------------------------------------
# inizio parte matriciale
#--------------------------------------------------------------
echo "CALCOLO ELEMENTI DI MATRICE..."
#prima riga, riporta gli estremi dei bin
awk -v "min=$LIMINF" -v "max=$LIMSUP" 'BEGIN {
                                               printf "%-6s  ", "/";
                                               for(i=min; i<max; ++i)
                                                printf "|%3d-%-3d ", i, i+1 ;
                                               print
                                             }'
#inizio valori
for ((xm=1; xm<=$NBINS; ++xm)); do
  #prima colonna,riporta gli estremi del bin
  awk -v "min=$LIMINF" -v "x=$xm" 'BEGIN {
                                          printf "%-d-%-3d  ", min+x-1, min+x
                                          }'
  for ((ym=1; ym<=$NBINS; ++ym)); do
    #estrae dal file media e deviazione standard del bin i e del bin j e le salva nelle rispettiva variabili
    MEAN_I=$( sed --silent "${xm}p" /tmp/meanSTD.txt | awk '{printf "%.8f", $1}')
    DEV_I=$( sed --silent "${xm}p" /tmp/meanSTD.txt | awk '{printf "%.8f", $2}')
    MEAN_J=$( sed --silent "${ym}p" /tmp/meanSTD.txt | awk '{printf "%.8f", $1}')
    DEV_J=$( sed --silent "${ym}p" /tmp/meanSTD.txt | awk '{printf "%.8f", $2}')
    COVARIANCE=0
    #calcola media e deviazione standard del prodotto bin i per bin j e li salva nelle rispettive variabili
    for ((n=1; n<=$NTPDF; ++n)); do
      TFILE=$(ls -1 *PDF$n-* | sed --silent "1p")
      VALUE_I=$(sed --silent "${xm}p" $TFILE | awk '{printf "%.8f", $3}')
      VALUE_J=$(sed --silent "${ym}p" $TFILE | awk '{printf "%.8f", $3}')
      COVARIANCE=$( echo "scale=8; $COVARIANCE + (${VALUE_I}-${MEAN_I})*(${VALUE_J}-${MEAN_J})/${NTPDF}" | bc)
    done
    CORRELATION=$( echo "scale=8; $COVARIANCE/($DEV_I*$DEV_J)" | bc)
    awk -v "C=$CORRELATION" 'BEGIN { printf " %7.4f ", C}'
  done
  awk 'BEGIN {print}'
done

rm -r $DIR
cd $START
