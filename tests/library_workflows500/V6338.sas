/* New workflow V6338; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6338i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80;
gene='gene01';c1='4.13';c2='-16.8';c3='68.27';c4='43.34';c5='39.410000000000004';output;
gene='gene02';c1='-21.74';c2='41.33';c3='-29.599999999999998';c4='-21.529999999999998';c5='64.54';output;
gene='gene03';c1='-22.61';c2='-19.54';c3='-6.470000000000001';c4='60.6';c5='70.67';output;
gene='gene04';c1='28.52';c2='-6.41';c3='51.660000000000004';c4='62.730000000000004';c5='64.8';output;
gene='gene05';c1='-5.35';c2='-16.28';c3='-14.209999999999999';c4='64.86';c5='65.93';output;
gene='gene06';c1='69.78';c2='62.85';c3='-27.08';c4='1.99';c5='-18.939999999999998';output;
gene='gene07';c1='12.91';c2='-23.02';c3='42.05';c4='-16.88';c5='17.19';output;
run;
%n26_char2num_dsd(dsdin=v6338i,vars=c1 c2 c3,dsdout=v6338o);
data v6338m(keep=metric value);set v6338o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6338m;set v6338m;format value best32.;run;
proc export data=v6338m outfile="%sysfunc(pathname(work))/V6338.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6338;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6338:;quit;
