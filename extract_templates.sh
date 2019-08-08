# script per estrarre vari .top di templates, pensato per agire nelle cartelle merged
# bisogna fornire come argomento il percorso assoluto del file di cui bisogna estrarre il grafico
# estrae le quantità desiderate e le salva in un file .top il cui nome è identico al file
# di partenza, ma preceduto da AFBe- dove e sta per estratto, nel caso della flag AFBe
# nel caso delle altre flag, salva in N-titolografico-NLO/alone.dat a seconda dei file scelti
# ATTENZIONE: SPOSTARE I FILE ESTRATTI IN UN ALTRA CARTELLA PRIMA DI ESTRARRE LO STESSO GRAFICO DA UN'ALTRO FILE NLO o alone, è pensato per i templates --> 1 file NLO e 1 file alone


# !/bin/bash
# controllo argomenti: 2 argomenti percorso assoluto alla directory e opzioni
if [ "$#" -ne 2  ] || ! [ ! -d "$2" ]; then
  echo "Usage [opzioni AFB, all, number, ] [path to file]"
  exit 1
fi
#start è la cartella da cui viene lanciato lo script
START=$(pwd)

#ISOLA IL NOME DEL FILE
FILE=$( echo $2 | awk -F/ '{print $NF}' )

#si pone nella cartella in cui è contenuto
DIR=${2%"${FILE}"}
cd ${DIR}

#------------------------------------------------- flag AFB --------------------------------------------------------------
if [ $1 == "AFB" ]; then
  #isola i grafici desiderati e li salva in file .txt
  sed --silent "/F-B index  34/,/X_m_report index  35/p" < ${FILE}  > F-B.txt
  sed --silent "/V_m index  30/,/V_m_report index  31/p" < ${FILE}  > VM.txt


  #rimuove prima e le le ultime 3 righe dai file .txt
  for DUMMY in F-B.txt VM.txt
  do
    sed -i '1d;$d' ${DUMMY}
    sed -i '$d' ${DUMMY}
    sed -i '$d' ${DUMMY}
  done
#crea un file composto da 12 colonne, costituito dai tre file txt affiancati
  paste F-B.txt VM.txt > total.txt

  #crea il file AFB, avendo nelle prime due colonne i bin, poi il valore e il suo errore
  #la formula usata per il calcolo dell'errore è riportata sotto
  awk ' BEGIN { format = "%14.7E  %14.7E  %14.7E  %14.7E\n" }
        {
          printf format, $1, $2, $3/($7), sqrt( ($4/($7))^2 + ($3*$8/($7)^2)^2  )
        }' < total.txt > AFB-${FILE}.dat

  # rimuove i file temporanei creati e si risposta nella cartella da cui era stato lanciato lo script
  rm F-B.txt VM.txt total.txt
  cd ${START}
  echo "\"AFB-${FILE}.dat\" creato"
  exit 1
fi

#------------------------------------------------- flag AFBPDF --------------------------------------------------------------

if [ $1 == "AFBPDF" ]; then
  #crea un suffisso per i file nlo oppure alone
  if [[ $FILE == *"NLO"* ]]; then
    SUFFIX="-NLO"
  fi
  if [[ $FILE == *"alone"* ]]; then
    SUFFIX="-alone"
  fi
  mkdir AFBPDF-$FILE
  npdf=1
  for ((ngraph=35; ngraph<235; ngraph=ngraph+2 )); do
	sgraph=$((ngraph+1))
        cat $FILE | sed -n "/index\s\{1,3\}${ngraph}\b/,/index\s\{1,3\}$((ngraph+1))\b/p" | sed '1d' | head -n -3 > "V-m.dat"
        cat $FILE | sed -n "/index\s\{1,3\}${sgraph}\b/,/index\s\{1,3\}$((sgraph+1))\b/p" | sed '1d' | head -n -3 > "F-B.dat"
        #crea un file composto da 12 colonne, costituito dai tre file txt affiancati
        paste F-B.dat V-m.dat > total.txt
        awk ' BEGIN { format = "%14.7E  %14.7E  %14.7E  %14.7E\n" }
              {
                printf format, $1, $2, $3/($7), sqrt( ($4/($7))^2 + ($3*$8/($7)^2)^2  )
              }' < total.txt > AFB-PDF${npdf}.dat
        mv AFB-PDF${npdf}.dat AFBPDF-$FILE
        echo "\"AFB-PDF${npdf}.dat\" creato" 
	npdf=$((++npdf))
  done
  rm F-B.dat V-m.dat total.txt
  cd ${START}
  exit 1
fi


#------------------------------------------------------------- flag all -------------------------------------------------------------------
if [ $1 == "all" ]; then

  #crea un suffisso per i file nlo oppure alone
  if [[ $FILE == *"NLO"* ]]; then
    SUFFIX="-NLO"
  fi
  if [[ $FILE == *"alone"* ]]; then
    SUFFIX="-alone"
  fi

  #prende ciascun grafico e lo salva in un file N-title-SUFFIX
  for ((ngraph=0; ngraph<473; ++ngraph)) do
       # salvataggio titolo
  		 TITLE=$(grep "index\s\{1,3\}${ngraph}\b" $FILE)
  		 TITLE=$(echo ${TITLE} | awk '{printf $2}')
       TITLE="$ngraph-$TITLE$SUFFIX"
       # isolamento valori del grafico e salvataggio in TITLE.txt
       cat $FILE | sed -n "/index\s\{1,3\}${ngraph}\b/,/index\s\{1,3\}$((ngraph+1))\b/p" | sed '1d' | head -n -3 > "$TITLE.dat"
       echo "\"$TITLE.dat\" creato"
  done

  cd ${START}
  exit 1
fi


# ------------------------------------------------- flag numero -------------------------------------------------------------------------
#regular expression per matchare numeri da 1 a 99
re='^([1-9]|[1-9]{1}[0-9]{1})$'
if [[ $1 =~ $re ]]; then

  #crea un suffisso per i file nlo oppure alone
  if [[ $FILE == *"NLO"* ]]; then
    SUFFIX="-NLO"
  fi
  if [[ $FILE == *"alone"* ]]; then
    SUFFIX="-alone"
  fi

  #prende ciascun grafico e lo salva in un file N-title-SUFFIX
  ngraph=$1
  # salvataggio titolo
  TITLE=$(grep "index\s\{1,3\}${ngraph}\b" $FILE)
  TITLE=$(echo ${TITLE} | awk '{printf $2}')
  TITLE="$ngraph-$TITLE$SUFFIX"
  # isolamento valori del grafico e salvataggio in TITLE.txt
  cat $FILE | sed -n "/index\s\{1,3\}${ngraph}\b/,/index\s\{1,3\}$((ngraph+1))\b/p" | sed '1d' | head -n -3 > "$TITLE.dat"
  echo "\"$TITLE.dat\" creato"

  cd ${START}
  exit 1
fi
#-----------------------------------------flag VMPDF--------------------------------------------------------------------------------------
#crea un suffisso per i file nlo oppure alone
if [ $1 == "VMPDF" ]; then

  if [[ $FILE == *"NLO"* ]]; then
    SUFFIX="-NLO"
  fi
  if [[ $FILE == *"alone"* ]]; then
    SUFFIX="-alone"
  fi
  mkdir VMPDF-$FILE
  for ((ngraph=35; ngraph<235; ngraph=ngraph+2)); do
    #prende ciascun grafico e lo salva in un file N-title-SUFFIX
    # salvataggio titolo
    TITLE=$(grep "index\s\{1,3\}${ngraph}\b" $FILE)
    TITLE=$(echo ${TITLE} | awk '{printf $2}')
    TITLE="$ngraph-$TITLE$SUFFIX"
    # isolamento valori del grafico e salvataggio in TITLE.txt
    cat $FILE | sed -n "/index\s\{1,3\}${ngraph}\b/,/index\s\{1,3\}$((ngraph+1))\b/p" | sed '1d' | head -n -3 > "$TITLE.dat"
    echo "\"$TITLE.dat\" creato"
    mv $TITLE.dat VMPDF-$FILE
  done
    cd ${START}
    exit 1

fi


  # per il calcolo dell'errore si hanno tre grandezze: F-B, F, B, con il relativo errore.
  # l'errore è la somma in quadratura delle derivate parziali della formula (F-B)/(F+B) rispetto alle 3 grandezze scritte sopra
  # ciascuna moltiplicata per l'errore della grandezza per cui si è derivato
  # Si sono sommati in quadratura i seguenti termini: a = F-B, b = B, c = F, err(a) indica l'errore di a
  # err(a)/(b+c) || a*err(b)/(b+c)^2 || a*err(c)/(b+c)^2
