#!/bin/bash
#crea le cartelle necessarie all'organizzazione delle quantità
cd /home/davidebadalotti/RUNS/QUANTITIES
FILE=/home/davidebadalotti/RUNS/TEMPLATES/singole_0.23126/pwg-NLO-2.top
for ((ngraph=0; ngraph<70; ++ngraph)) do
  TITLE=$(grep "index\s\{2,3\}${ngraph}\b" $FILE)
  TITLE=$(echo ${TITLE} | awk '{printf $2}')
  TITLE="$ngraph-$TITLE"
  mkdir alone/$TITLE
  mkdir NLO/$TITLE
done
