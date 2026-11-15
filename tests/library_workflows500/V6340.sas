/* New workflow V6340; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6340i;
length gene $80 c1 $80 c2 $80;
gene='gene01';c1='-11.87';c2='-29.8';output;
gene='gene02';c1='-11.74';c2='25.330000000000002';output;
gene='gene03';c1='4.39';c2='47.46';output;
gene='gene04';c1='-27.48';c2='49.59';output;
gene='gene05';c1='59.65';c2='24.72';output;
gene='gene06';c1='-16.22';c2='56.85';output;
gene='gene07';c1='29.91';c2='-24.02';output;
gene='gene08';c1='30.04';c2='-8.89';output;
gene='gene09';c1='42.17';c2='53.24';output;
run;
%n26_char2num_dsd(dsdin=v6340i,vars=c1 c2,dsdout=v6340o);
data v6340m(keep=metric value);set v6340o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6340m;set v6340m;format value best32.;run;
proc export data=v6340m outfile="%sysfunc(pathname(work))/V6340.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6340;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6340:;quit;
