#!/bin/bash

if[ $# -eq 1 ]
then
  MYDIR=/home/davidebadalotti/tesi/
  risultati=${MYDIR}run-test

  mkdir -p $risultati

  for ((irnd=1; irnd<$1; ++irnd))
  do

  rndlist=$irnd
  echo $rndlist

  inputfile=powheg.input-$irnd

  sed     -e "s:seeddummy:$rndlist:"\
      < powheg.input-dummy > $inputfile



  echo "#!/bin/bash
  cd "'$TMPDIR'"
  cp ${MYDIR}pwhg_main .
  cp $MYDIR/$inputfile powheg.input
  ./pwhg_main < powheg.input > out0
  cp  pwg-NLO.top $MYDIR/$risultati/pwg-NLO-$irnd.top
  cp  pwgpwhgalone-output.top $MYDIR/$risultati/pwgpwhgalone-output-$irnd.top
  " > a.sh

  cat a.sh


  qsub -l walltime=480:00:00 -l pmem=500mb -l nodes=1:ppn=1 -q fast a.sh ;

  sleep 1s
  done
else
  echo "Argomenti non corretti."
fi
