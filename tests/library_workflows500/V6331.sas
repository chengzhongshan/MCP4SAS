/* New workflow V6331; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6331i;
length gene $80 c1 $80 c2 $80 c3 $80;
gene='gene01';c1='-11.87';c2='70.19999999999999';c3='-25.73';output;
gene='gene02';c1='26.26';c2='15.33';c3='-16.599999999999998';output;
gene='gene03';c1='53.39';c2='51.46';c3='61.53';output;
gene='gene04';c1='-19.48';c2='49.59';c3='-18.34';output;
gene='gene05';c1='9.65';c2='34.72';c3='14.790000000000001';output;
gene='gene06';c1='34.78';c2='-29.15';c3='61.92';output;
gene='gene07';c1='-19.09';c2='60.98';c3='-8.95';output;
run;
%n26_char2num_dsd(dsdin=v6331i,vars=c1 c2 c3,dsdout=v6331o);
data v6331m(keep=metric value);set v6331o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6331m;set v6331m;format value best32.;run;
proc export data=v6331m outfile="%sysfunc(pathname(work))/V6331.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6331;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6331:;quit;
