/* New workflow V6326; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6326i;
length gene $80 c1 $80 c2 $80 c3 $80;
gene='gene01';c1='2.13';c2='13.200000000000001';c3='52.27';output;
gene='gene02';c1='-24.74';c2='6.33';c3='42.4';output;
gene='gene03';c1='35.39';c2='20.46';c3='69.53';output;
gene='gene04';c1='33.52';c2='-28.41';c3='-0.33999999999999997';output;
gene='gene05';c1='13.65';c2='-24.28';c3='54.79';output;
gene='gene06';c1='61.78';c2='10.85';c3='-16.08';output;
gene='gene07';c1='49.91';c2='28.98';c3='-23.95';output;
gene='gene08';c1='-3.96';c2='71.11';c3='-11.82';output;
gene='gene09';c1='19.17';c2='64.24';c3='35.31';output;
run;
%n26_char2num_dsd(dsdin=v6326i,vars=c1 c2 c3,dsdout=v6326o);
data v6326m(keep=metric value);set v6326o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6326m;set v6326m;format value best32.;run;
proc export data=v6326m outfile="%sysfunc(pathname(work))/V6326.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6326;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6326:;quit;
