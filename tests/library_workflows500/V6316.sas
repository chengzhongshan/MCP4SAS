/* New workflow V6316; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6316i;
length gene $80 c1 $80 c2 $80 c3 $80;
gene='gene01';c1='13.13';c2='0.2';c3='30.27';output;
gene='gene02';c1='66.26';c2='-20.669999999999998';c3='13.4';output;
gene='gene03';c1='39.39';c2='-13.54';c3='-29.47';output;
gene='gene04';c1='-21.48';c2='7.59';c3='3.66';output;
gene='gene05';c1='-23.35';c2='7.720000000000001';c3='-11.209999999999999';output;
run;
%n26_char2num_dsd(dsdin=v6316i,vars=c1,dsdout=v6316o);
data v6316m(keep=metric value);set v6316o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6316m;set v6316m;format value best32.;run;
proc export data=v6316m outfile="%sysfunc(pathname(work))/V6316.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6316;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6316:;quit;
