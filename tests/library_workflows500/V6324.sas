/* New workflow V6324; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6324i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80 c6 $80;
gene='gene01';c1='64.13';c2='-1.8';c3='-16.73';c4='16.34';c5='25.41';c6='-26.52';output;
gene='gene02';c1='20.26';c2='32.33';c3='-5.6000000000000005';c4='9.47';c5='48.54';c6='51.61';output;
gene='gene03';c1='5.39';c2='14.46';c3='29.53';c4='21.6';c5='46.67';c6='21.740000000000002';output;
gene='gene04';c1='64.52';c2='11.59';c3='0.66';c4='-25.27';c5='12.799999999999999';c6='66.86999999999999';output;
gene='gene05';c1='-11.35';c2='25.72';c3='46.79';c4='-8.139999999999999';c5='15.93';c6='48.0';output;
gene='gene06';c1='36.78';c2='59.85';c3='-23.08';c4='42.99';c5='71.06';c6='43.13';output;
gene='gene07';c1='-1.0899999999999999';c2='-21.02';c3='54.05';c4='-21.88';c5='12.19';c6='64.25999999999999';output;
run;
%n26_char2num_dsd(dsdin=v6324i,vars=c1 c2 c3,dsdout=v6324o);
data v6324m(keep=metric value);set v6324o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6324m;set v6324m;format value best32.;run;
proc export data=v6324m outfile="%sysfunc(pathname(work))/V6324.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6324;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6324:;quit;
