/* New workflow V6306; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6306i;
length gene $80 c1 $80 c2 $80 c3 $80;
gene='gene01';c1='-20.87';c2='-2.8000000000000003';c3='52.27';output;
gene='gene02';c1='28.26';c2='40.33';c3='12.4';output;
gene='gene03';c1='6.39';c2='-4.54';c3='-29.47';output;
gene='gene04';c1='-14.48';c2='-0.41';c3='66.66';output;
gene='gene05';c1='70.65';c2='18.72';c3='32.79';output;
gene='gene06';c1='29.78';c2='-15.15';c3='62.92';output;
gene='gene07';c1='31.91';c2='25.98';c3='-14.95';output;
gene='gene08';c1='45.04';c2='32.11';c3='-16.82';output;
gene='gene09';c1='21.17';c2='49.24';c3='68.31';output;
run;
%n26_char2num_dsd(dsdin=v6306i,vars=c1,dsdout=v6306o);
data v6306m(keep=metric value);set v6306o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6306m;set v6306m;format value best32.;run;
proc export data=v6306m outfile="%sysfunc(pathname(work))/V6306.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6306;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6306:;quit;
