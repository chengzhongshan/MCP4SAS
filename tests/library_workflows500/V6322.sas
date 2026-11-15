/* New workflow V6322; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6322i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80;
gene='gene01';c1='15.13';c2='33.2';c3='10.270000000000001';c4='21.34';output;
gene='gene02';c1='64.26';c2='-27.669999999999998';c3='-22.599999999999998';c4='51.47';output;
gene='gene03';c1='48.39';c2='26.46';c3='31.53';c4='36.6';output;
gene='gene04';c1='3.52';c2='13.59';c3='55.660000000000004';c4='-13.27';output;
gene='gene05';c1='-1.35';c2='-3.2800000000000002';c3='42.79';c4='-15.139999999999999';output;
run;
%n26_char2num_dsd(dsdin=v6322i,vars=c1 c2 c3,dsdout=v6322o);
data v6322m(keep=metric value);set v6322o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6322m;set v6322m;format value best32.;run;
proc export data=v6322m outfile="%sysfunc(pathname(work))/V6322.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6322;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6322:;quit;
