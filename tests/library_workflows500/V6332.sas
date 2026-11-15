/* New workflow V6332; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6332i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80;
gene='gene01';c1='27.13';c2='14.200000000000001';c3='-2.73';c4='57.34';output;
gene='gene02';c1='55.26';c2='-28.669999999999998';c3='21.400000000000002';c4='14.47';output;
gene='gene03';c1='11.39';c2='63.46';c3='70.53';c4='4.6';output;
gene='gene04';c1='-0.48';c2='10.59';c3='44.660000000000004';c4='-28.27';output;
gene='gene05';c1='-26.35';c2='14.72';c3='56.79';c4='29.86';output;
gene='gene06';c1='70.78';c2='-19.15';c3='26.92';c4='49.99';output;
gene='gene07';c1='19.91';c2='62.98';c3='28.05';c4='-25.88';output;
gene='gene08';c1='39.04';c2='-22.89';c3='-6.82';c4='-20.75';output;
run;
%n26_char2num_dsd(dsdin=v6332i,vars=c1 c2 c3,dsdout=v6332o);
data v6332m(keep=metric value);set v6332o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6332m;set v6332m;format value best32.;run;
proc export data=v6332m outfile="%sysfunc(pathname(work))/V6332.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6332;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6332:;quit;
