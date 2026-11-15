/* New workflow V6317; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6317i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80;
gene='gene01';c1='-7.87';c2='18.2';c3='65.27';c4='68.33999999999999';output;
gene='gene02';c1='37.26';c2='18.330000000000002';c3='-19.599999999999998';c4='-17.529999999999998';output;
gene='gene03';c1='53.39';c2='29.46';c3='44.53';c4='11.600000000000001';output;
gene='gene04';c1='68.52';c2='69.58999999999999';c3='-18.34';c4='17.73';output;
gene='gene05';c1='22.65';c2='62.72';c3='-25.21';c4='-15.139999999999999';output;
gene='gene06';c1='44.78';c2='0.8500000000000001';c3='-2.0799999999999996';c4='-20.009999999999998';output;
run;
%n26_char2num_dsd(dsdin=v6317i,vars=c1,dsdout=v6317o);
data v6317m(keep=metric value);set v6317o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6317m;set v6317m;format value best32.;run;
proc export data=v6317m outfile="%sysfunc(pathname(work))/V6317.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6317;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6317:;quit;
