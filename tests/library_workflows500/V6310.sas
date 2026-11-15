/* New workflow V6310; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6310i;
length gene $80 c1 $80 c2 $80;
gene='gene01';c1='17.13';c2='32.2';output;
gene='gene02';c1='43.26';c2='53.33';output;
gene='gene03';c1='28.39';c2='44.46';output;
gene='gene04';c1='6.52';c2='-11.41';output;
gene='gene05';c1='46.65';c2='36.72';output;
gene='gene06';c1='59.78';c2='-5.1499999999999995';output;
run;
%n26_char2num_dsd(dsdin=v6310i,vars=c1,dsdout=v6310o);
data v6310m(keep=metric value);set v6310o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6310m;set v6310m;format value best32.;run;
proc export data=v6310m outfile="%sysfunc(pathname(work))/V6310.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6310;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6310:;quit;
