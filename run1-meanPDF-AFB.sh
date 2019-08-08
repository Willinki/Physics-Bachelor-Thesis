#!/bin/bash
#-----------------------
# definizione parametri
#-----------------------
START=$(pwd)
FDIR="/home/davidebadalotti/RUNS/run2-meanstdPDF-medium-19.08.03"
FILENAME=pwg-NLO-500.top
PDFDIR=${FDIR}/AFBPDF-${FILENAME}
COMP="34"
#-----------------------
# fine parametri
#-----------------------
if [[ $FILENAME == *"NLO"* ]]; then
	SUFFIX="NLO"
fi
if  [[ $FILENAME == *"alone"* ]]; then
	SUFFIX="alone"
fi

echo "ESTRAZIONE GRAFICI..."
/home/davidebadalotti/Tesi/dati_scripts/extract_templates.sh AFBPDF $FDIR/$FILENAME > /dev/null
cd $PDFDIR
echo "CALCOLO MINIMI CHI2..."
printf "" > $FDIR/chi2-minimums.dat
n=0
for file in $(ls -1); do
	n=$((++n));
	echo -ne "$n/100"'\r'
	/home/davidebadalotti/Tesi/dati_scripts/compare_templates.sh ${PDFDIR}/$file $SUFFIX $COMP >>  $FDIR/chi2-minimums.dat 2> /dev/null
done
MEAN=$( awk 'BEGIN{s=0;}{s=s+$1;}END{print s/NR;}' $FDIR/chi2-minimums.dat )
STD=$(  awk '{delta = $1 - avg; avg += delta / NR; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR); }' $FDIR/chi2-minimums.dat )
echo "--------------------"
echo "- MEAN: $MEAN   -"
echo "- STD: $STD  -"
echo "- EXP: 0.23156     -"
echo "--------------------"
cd $START
rm -r $PDFDIR
