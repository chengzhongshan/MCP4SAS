/* New workflow V6335; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6335i;
length gene $80 c1 $80 c2 $80;
gene='gene01';c1='64.13';c2='57.2';output;
gene='gene02';c1='70.26';c2='64.33';output;
gene='gene03';c1='6.39';c2='47.46';output;
gene='gene04';c1='4.52';c2='62.59';output;
run;
%n26_char2num_dsd(dsdin=v6335i,vars=c1 c2,dsdout=v6335o);
data v6335m(keep=metric value);set v6335o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6335m;set v6335m;format value best32.;run;
proc export data=v6335m outfile="%sysfunc(pathname(work))/V6335.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6335;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6335:;quit;
