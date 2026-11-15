/* New workflow V6327; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6327i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80;
gene='gene01';c1='7.13';c2='-9.799999999999999';c3='-11.729999999999999';c4='-24.66';output;
gene='gene02';c1='47.26';c2='45.33';c3='-3.6';c4='36.47';output;
gene='gene03';c1='34.39';c2='67.46';c3='13.530000000000001';c4='43.6';output;
run;
%n26_char2num_dsd(dsdin=v6327i,vars=c1 c2 c3,dsdout=v6327o);
data v6327m(keep=metric value);set v6327o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6327m;set v6327m;format value best32.;run;
proc export data=v6327m outfile="%sysfunc(pathname(work))/V6327.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6327;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6327:;quit;
