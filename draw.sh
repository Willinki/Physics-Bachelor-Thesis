#!/bin/bash
# per plottare occorre inserire IL PERCORSO ASSOLUTO DELLA CARTELLA in cui sono contenuti i file .top, vengono plottati tutti i file .top
if [[ $# -eq 1 ]]
then

	MYDIR=/home/davidebadalotti/Tesi/totali_scripts
	directory=$1
	ls ${directory} | grep .top > list.txt
	while read filename; do
 	 filetobedrawn=${directory}/${filename}
	 drawingfolder=${filetobedrawn}_drawn
 	 mkdir -p ${drawingfolder}
	 cp ${MYDIR}/draw_and_export $drawingfolder
 	 for ((ngraph=2; ngraph<70; ++ngraph)) do
   		 NUMBER=$ngraph
   		 TITLE=$(grep "index\s\{2,3\}${ngraph}\b" ${filetobedrawn})
   		 TITLE=$(echo ${TITLE} | awk '{printf $2}')
   		 cat ${filetobedrawn} | sed -n "/index\s\{2,3\}${ngraph}\b/,/index\s\{2,3\}$((ngraph+1))\b/p" | sed '1d' | head -n -3 > $drawingfolder/dummy.txt
			 cd $drawingfolder
   		 ./draw_and_export ${TITLE} ${NUMBER}
   		 #crea un file di nome $number$title.ps
			 cd ..
   done
	done < list.txt
	rm list.txt dummy.txt draw_and_export
else
	echo "Argomenti non corretti"
fi
