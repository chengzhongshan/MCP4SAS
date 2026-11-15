/* New workflow V6312; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6312i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80;
gene='gene01';c1='66.13';c2='42.2';c3='23.27';c4='28.34';output;
gene='gene02';c1='59.26';c2='51.33';c3='-14.6';c4='5.47';output;
gene='gene03';c1='18.39';c2='-15.54';c3='-10.469999999999999';c4='28.6';output;
gene='gene04';c1='-9.48';c2='16.59';c3='21.66';c4='34.730000000000004';output;
gene='gene05';c1='18.65';c2='50.72';c3='19.79';c4='35.86';output;
gene='gene06';c1='-16.22';c2='61.85';c3='17.92';c4='13.99';output;
gene='gene07';c1='-1.0899999999999999';c2='15.98';c3='6.05';c4='12.120000000000001';output;
gene='gene08';c1='-20.96';c2='37.11';c3='7.18';c4='63.25';output;
run;
%n26_char2num_dsd(dsdin=v6312i,vars=c1,dsdout=v6312o);
data v6312m(keep=metric value);set v6312o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6312m;set v6312m;format value best32.;run;
proc export data=v6312m outfile="%sysfunc(pathname(work))/V6312.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6312;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6312:;quit;
