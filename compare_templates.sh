#!/bin/bash
# argomenti: file - NLO,alone - Ngraph
if [ $# -ne 3 ]; then
       echo "Usage: [path to file] [NLO/alone] [Ntemplates]"
       exit 1
fi
if [[ $2 != "alone" &&  $2 != "NLO" ]]; then
	echo 'Usage $2: [NLO - alone]'
	exit 1
fi

#-------------------------------------
# DEFINIZIONE PARAMETRI
#-------------------------------------
START=$(pwd)
FILE=$( echo $1 | awk -F/ '{print $NF}' )
DIR=${1%"${FILE}"}
TEMPLATES=/home/davidebadalotti/RUNS/QUANTITIES/$2
TDIR=$( ls -d $TEMPLATES/$3-*)
DESTD=$DIR/testchi2-$FILE-$2-$3
cd $DIR
mkdir testchi2-$FILE-$2-$3
cd $START
printf ""  > $DESTD/chi2-values.txt
for file in $(ls -1 $TDIR/sin*); do
	XVALUE=$( echo $file | awk -F/ '{print $NF}' )
	XVALUE=${XVALUE#"sin-"}
	printf "%.8s	" $XVALUE >> $DESTD/chi2-values.txt
	/home/davidebadalotti/Tesi/singoli_scripts/confronto_chi2.sh $1 $file >> $DESTD/chi2-values.txt 
done
cp /home/davidebadalotti/Tesi/dati_scripts/plotchi2 $DESTD
cd $DESTD
./plotchi2
rm plotchi2
cd $START
