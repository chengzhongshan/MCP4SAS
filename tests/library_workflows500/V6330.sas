/* New workflow V6330; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6330i;
length gene $80 c1 $80 c2 $80;
gene='gene01';c1='12.13';c2='68.19999999999999';output;
gene='gene02';c1='10.26';c2='58.33';output;
gene='gene03';c1='13.39';c2='13.46';output;
gene='gene04';c1='15.52';c2='52.59';output;
gene='gene05';c1='43.65';c2='-23.28';output;
gene='gene06';c1='-8.22';c2='-24.15';output;
run;
%n26_char2num_dsd(dsdin=v6330i,vars=c1 c2,dsdout=v6330o);
data v6330m(keep=metric value);set v6330o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6330m;set v6330m;format value best32.;run;
proc export data=v6330m outfile="%sysfunc(pathname(work))/V6330.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6330;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6330:;quit;
