/* New workflow V6318; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6318i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80;
gene='gene01';c1='31.13';c2='55.2';c3='-3.73';c4='49.34';c5='22.41';output;
gene='gene02';c1='22.26';c2='-1.67';c3='9.4';c4='44.47';c5='35.54';output;
gene='gene03';c1='65.39';c2='38.46';c3='10.530000000000001';c4='62.6';c5='-21.33';output;
gene='gene04';c1='54.52';c2='48.59';c3='59.660000000000004';c4='16.73';c5='28.8';output;
gene='gene05';c1='-26.35';c2='19.72';c3='-18.21';c4='-0.13999999999999996';c5='12.93';output;
gene='gene06';c1='66.78';c2='-7.1499999999999995';c3='-17.08';c4='66.99';c5='52.06';output;
gene='gene07';c1='65.91';c2='46.98';c3='-2.9499999999999997';c4='65.11999999999999';c5='41.19';output;
run;
%n26_char2num_dsd(dsdin=v6318i,vars=c1,dsdout=v6318o);
data v6318m(keep=metric value);set v6318o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6318m;set v6318m;format value best32.;run;
proc export data=v6318m outfile="%sysfunc(pathname(work))/V6318.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6318;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6318:;quit;
