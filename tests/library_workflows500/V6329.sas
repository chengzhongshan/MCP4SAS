/* New workflow V6329; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6329i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80 c6 $80;
gene='gene01';c1='-18.87';c2='36.2';c3='60.27';c4='35.34';c5='20.41';c6='-23.52';output;
gene='gene02';c1='15.26';c2='26.330000000000002';c3='29.400000000000002';c4='-6.53';c5='3.54';c6='37.61';output;
gene='gene03';c1='43.39';c2='-2.54';c3='15.530000000000001';c4='52.6';c5='11.67';c6='56.74';output;
gene='gene04';c1='62.52';c2='39.59';c3='58.660000000000004';c4='36.730000000000004';c5='24.8';c6='-6.130000000000001';output;
gene='gene05';c1='20.65';c2='2.7199999999999998';c3='45.79';c4='-17.14';c5='61.93';c6='31.0';output;
run;
%n26_char2num_dsd(dsdin=v6329i,vars=c1 c2 c3,dsdout=v6329o);
data v6329m(keep=metric value);set v6329o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6329m;set v6329m;format value best32.;run;
proc export data=v6329m outfile="%sysfunc(pathname(work))/V6329.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6329;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6329:;quit;
