/* New workflow V6334; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6334i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80 c6 $80;
gene='gene01';c1='23.13';c2='64.19999999999999';c3='61.27';c4='39.34';c5='13.41';c6='-26.52';output;
gene='gene02';c1='53.26';c2='32.33';c3='-28.599999999999998';c4='61.47';c5='40.54';c6='-24.389999999999997';output;
gene='gene03';c1='-16.61';c2='0.46';c3='17.53';c4='6.6';c5='63.67';c6='57.74';output;
run;
%n26_char2num_dsd(dsdin=v6334i,vars=c1 c2 c3,dsdout=v6334o);
data v6334m(keep=metric value);set v6334o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6334m;set v6334m;format value best32.;run;
proc export data=v6334m outfile="%sysfunc(pathname(work))/V6334.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6334;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6334:;quit;
