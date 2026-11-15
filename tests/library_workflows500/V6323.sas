/* New workflow V6323; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6323i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80;
gene='gene01';c1='-19.87';c2='58.2';c3='20.27';c4='4.34';c5='-18.59';output;
gene='gene02';c1='-11.74';c2='49.33';c3='19.400000000000002';c4='51.47';c5='-1.46';output;
gene='gene03';c1='-2.61';c2='-0.54';c3='23.53';c4='24.6';c5='53.67';output;
gene='gene04';c1='13.52';c2='9.59';c3='-9.34';c4='-15.27';c5='49.800000000000004';output;
gene='gene05';c1='55.65';c2='-17.28';c3='49.79';c4='61.86';c5='51.93';output;
gene='gene06';c1='26.78';c2='-3.15';c3='-2.0799999999999996';c4='42.99';c5='-28.939999999999998';output;
run;
%n26_char2num_dsd(dsdin=v6323i,vars=c1 c2 c3,dsdout=v6323o);
data v6323m(keep=metric value);set v6323o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6323m;set v6323m;format value best32.;run;
proc export data=v6323m outfile="%sysfunc(pathname(work))/V6323.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6323;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6323:;quit;
