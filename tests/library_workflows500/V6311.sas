/* New workflow V6311; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6311i;
length gene $80 c1 $80 c2 $80 c3 $80;
gene='gene01';c1='48.13';c2='-13.799999999999999';c3='47.27';output;
gene='gene02';c1='-7.74';c2='56.33';c3='63.4';output;
gene='gene03';c1='66.39';c2='-19.54';c3='28.53';output;
gene='gene04';c1='31.52';c2='-12.41';c3='-16.34';output;
gene='gene05';c1='52.65';c2='-16.28';c3='-22.21';output;
gene='gene06';c1='40.78';c2='13.85';c3='-20.08';output;
gene='gene07';c1='61.91';c2='9.98';c3='71.05';output;
run;
%n26_char2num_dsd(dsdin=v6311i,vars=c1,dsdout=v6311o);
data v6311m(keep=metric value);set v6311o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6311m;set v6311m;format value best32.;run;
proc export data=v6311m outfile="%sysfunc(pathname(work))/V6311.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6311;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6311:;quit;
