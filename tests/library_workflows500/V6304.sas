/* New workflow V6304; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6304i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80 c6 $80;
gene='gene01';c1='50.13';c2='59.2';c3='-19.73';c4='-9.659999999999998';c5='64.41';c6='11.48';output;
gene='gene02';c1='36.26';c2='9.33';c3='8.4';c4='54.47';c5='40.54';c6='51.61';output;
gene='gene03';c1='67.39';c2='-14.54';c3='51.53';c4='56.6';c5='26.67';c6='-21.259999999999998';output;
gene='gene04';c1='34.52';c2='63.59';c3='50.660000000000004';c4='16.73';c5='69.8';c6='20.87';output;
gene='gene05';c1='53.65';c2='48.72';c3='-5.21';c4='20.86';c5='62.93';c6='-20.0';output;
gene='gene06';c1='-4.22';c2='18.85';c3='65.92';c4='-5.01';c5='-13.940000000000001';c6='32.13';output;
gene='gene07';c1='-26.09';c2='4.98';c3='-19.95';c4='14.120000000000001';c5='17.19';c6='62.26';output;
run;
%n26_char2num_dsd(dsdin=v6304i,vars=c1,dsdout=v6304o);
data v6304m(keep=metric value);set v6304o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6304m;set v6304m;format value best32.;run;
proc export data=v6304m outfile="%sysfunc(pathname(work))/V6304.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6304;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6304:;quit;
