/* New workflow V6314; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6314i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80 c6 $80;
gene='gene01';c1='9.13';c2='-25.8';c3='58.27';c4='1.3399999999999999';c5='25.41';c6='30.48';output;
gene='gene02';c1='53.26';c2='-22.669999999999998';c3='-0.6';c4='36.47';c5='55.54';c6='-9.39';output;
gene='gene03';c1='3.39';c2='14.46';c3='33.53';c4='49.6';c5='23.67';c6='-11.26';output;
run;
%n26_char2num_dsd(dsdin=v6314i,vars=c1,dsdout=v6314o);
data v6314m(keep=metric value);set v6314o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6314m;set v6314m;format value best32.;run;
proc export data=v6314m outfile="%sysfunc(pathname(work))/V6314.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6314;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6314:;quit;
