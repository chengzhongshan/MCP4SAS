/* New workflow V6325; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6325i;
length gene $80 c1 $80 c2 $80;
gene='gene01';c1='37.13';c2='-0.8';output;
gene='gene02';c1='5.26';c2='23.330000000000002';output;
gene='gene03';c1='52.39';c2='-29.54';output;
gene='gene04';c1='24.52';c2='26.59';output;
gene='gene05';c1='9.65';c2='48.72';output;
gene='gene06';c1='34.78';c2='-1.15';output;
gene='gene07';c1='58.91';c2='68.97999999999999';output;
gene='gene08';c1='33.04';c2='48.11';output;
run;
%n26_char2num_dsd(dsdin=v6325i,vars=c1 c2,dsdout=v6325o);
data v6325m(keep=metric value);set v6325o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6325m;set v6325m;format value best32.;run;
proc export data=v6325m outfile="%sysfunc(pathname(work))/V6325.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6325;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6325:;quit;
