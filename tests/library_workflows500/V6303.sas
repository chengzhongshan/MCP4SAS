/* New workflow V6303; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6303i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80;
gene='gene01';c1='46.13';c2='66.19999999999999';c3='15.270000000000001';c4='6.34';c5='13.41';output;
gene='gene02';c1='32.26';c2='17.330000000000002';c3='-23.599999999999998';c4='-21.529999999999998';c5='42.54';output;
gene='gene03';c1='-28.61';c2='13.46';c3='52.53';c4='4.6';c5='32.67';output;
gene='gene04';c1='19.52';c2='-9.41';c3='-21.34';c4='27.73';c5='12.799999999999999';output;
gene='gene05';c1='51.65';c2='42.72';c3='3.79';c4='-26.14';c5='16.93';output;
gene='gene06';c1='24.78';c2='4.8500000000000005';c3='-19.08';c4='-13.01';c5='29.060000000000002';output;
run;
%n26_char2num_dsd(dsdin=v6303i,vars=c1,dsdout=v6303o);
data v6303m(keep=metric value);set v6303o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6303m;set v6303m;format value best32.;run;
proc export data=v6303m outfile="%sysfunc(pathname(work))/V6303.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6303;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6303:;quit;
