/* New workflow V6309; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6309i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80 c6 $80;
gene='gene01';c1='13.13';c2='7.2';c3='48.27';c4='16.34';c5='-22.59';c6='47.480000000000004';output;
gene='gene02';c1='-29.74';c2='27.330000000000002';c3='-10.6';c4='51.47';c5='31.540000000000003';c6='-21.389999999999997';output;
gene='gene03';c1='-6.61';c2='27.46';c3='38.53';c4='52.6';c5='14.67';c6='47.74';output;
gene='gene04';c1='30.52';c2='-19.41';c3='21.66';c4='62.730000000000004';c5='36.800000000000004';c6='44.870000000000005';output;
gene='gene05';c1='0.65';c2='51.72';c3='31.79';c4='-20.14';c5='-20.07';c6='44.0';output;
run;
%n26_char2num_dsd(dsdin=v6309i,vars=c1,dsdout=v6309o);
data v6309m(keep=metric value);set v6309o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6309m;set v6309m;format value best32.;run;
proc export data=v6309m outfile="%sysfunc(pathname(work))/V6309.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6309;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6309:;quit;
