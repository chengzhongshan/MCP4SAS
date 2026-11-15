/* New workflow V6308; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6308i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80;
gene='gene01';c1='55.13';c2='31.2';c3='24.27';c4='47.34';c5='-1.59';output;
gene='gene02';c1='57.26';c2='-9.67';c3='33.4';c4='6.47';c5='67.54';output;
gene='gene03';c1='22.39';c2='12.46';c3='22.53';c4='39.6';c5='64.67';output;
gene='gene04';c1='44.52';c2='31.59';c3='-29.34';c4='66.72999999999999';c5='-29.2';output;
run;
%n26_char2num_dsd(dsdin=v6308i,vars=c1,dsdout=v6308o);
data v6308m(keep=metric value);set v6308o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6308m;set v6308m;format value best32.;run;
proc export data=v6308m outfile="%sysfunc(pathname(work))/V6308.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6308;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6308:;quit;
