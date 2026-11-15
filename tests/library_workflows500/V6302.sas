/* New workflow V6302; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6302i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80;
gene='gene01';c1='-19.87';c2='46.2';c3='63.27';c4='52.34';output;
gene='gene02';c1='46.26';c2='-10.67';c3='0.4';c4='-4.53';output;
gene='gene03';c1='-10.61';c2='48.46';c3='62.53';c4='58.6';output;
gene='gene04';c1='-22.48';c2='46.59';c3='16.66';c4='-7.2700000000000005';output;
gene='gene05';c1='-18.35';c2='2.7199999999999998';c3='26.79';c4='-13.139999999999999';output;
run;
%n26_char2num_dsd(dsdin=v6302i,vars=c1,dsdout=v6302o);
data v6302m(keep=metric value);set v6302o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6302m;set v6302m;format value best32.;run;
proc export data=v6302m outfile="%sysfunc(pathname(work))/V6302.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6302;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6302:;quit;
