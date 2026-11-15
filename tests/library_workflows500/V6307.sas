/* New workflow V6307; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6307i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80;
gene='gene01';c1='-4.87';c2='-19.8';c3='70.27';c4='44.34';output;
gene='gene02';c1='-22.74';c2='5.33';c3='-16.599999999999998';c4='-21.529999999999998';output;
gene='gene03';c1='3.39';c2='43.46';c3='41.53';c4='-11.399999999999999';output;
run;
%n26_char2num_dsd(dsdin=v6307i,vars=c1,dsdout=v6307o);
data v6307m(keep=metric value);set v6307o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6307m;set v6307m;format value best32.;run;
proc export data=v6307m outfile="%sysfunc(pathname(work))/V6307.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6307;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6307:;quit;
