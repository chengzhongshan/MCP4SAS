/* New workflow V6320; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6320i;
length gene $80 c1 $80 c2 $80;
gene='gene01';c1='-26.87';c2='45.2';output;
gene='gene02';c1='38.26';c2='18.330000000000002';output;
gene='gene03';c1='69.39';c2='31.46';output;
gene='gene04';c1='29.52';c2='13.59';output;
gene='gene05';c1='-8.35';c2='65.72';output;
gene='gene06';c1='3.7800000000000002';c2='-26.15';output;
gene='gene07';c1='44.91';c2='-25.02';output;
gene='gene08';c1='56.04';c2='8.11';output;
gene='gene09';c1='-8.83';c2='34.24';output;
run;
%n26_char2num_dsd(dsdin=v6320i,vars=c1,dsdout=v6320o);
data v6320m(keep=metric value);set v6320o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6320m;set v6320m;format value best32.;run;
proc export data=v6320m outfile="%sysfunc(pathname(work))/V6320.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6320;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6320:;quit;
