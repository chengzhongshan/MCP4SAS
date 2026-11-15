/* New workflow V6337; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6337i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80;
gene='gene01';c1='51.13';c2='67.19999999999999';c3='21.27';c4='59.34';output;
gene='gene02';c1='9.26';c2='6.33';c3='18.400000000000002';c4='13.47';output;
gene='gene03';c1='3.39';c2='40.46';c3='-7.470000000000001';c4='46.6';output;
gene='gene04';c1='40.52';c2='-15.41';c3='-28.34';c4='51.730000000000004';output;
gene='gene05';c1='-15.35';c2='-6.279999999999999';c3='59.79';c4='-12.139999999999999';output;
gene='gene06';c1='-20.22';c2='59.85';c3='43.92';c4='-14.01';output;
run;
%n26_char2num_dsd(dsdin=v6337i,vars=c1 c2 c3,dsdout=v6337o);
data v6337m(keep=metric value);set v6337o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6337m;set v6337m;format value best32.;run;
proc export data=v6337m outfile="%sysfunc(pathname(work))/V6337.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6337;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6337:;quit;
