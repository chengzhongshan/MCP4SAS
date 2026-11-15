/* New workflow V6305; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6305i;
length gene $80 c1 $80 c2 $80;
gene='gene01';c1='-18.87';c2='26.2';output;
gene='gene02';c1='55.26';c2='-3.6700000000000004';output;
gene='gene03';c1='-13.61';c2='40.46';output;
gene='gene04';c1='-25.48';c2='7.59';output;
gene='gene05';c1='-18.35';c2='-19.28';output;
gene='gene06';c1='8.78';c2='10.85';output;
gene='gene07';c1='39.91';c2='11.98';output;
gene='gene08';c1='65.04';c2='27.11';output;
run;
%n26_char2num_dsd(dsdin=v6305i,vars=c1,dsdout=v6305o);
data v6305m(keep=metric value);set v6305o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6305m;set v6305m;format value best32.;run;
proc export data=v6305m outfile="%sysfunc(pathname(work))/V6305.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6305;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6305:;quit;
