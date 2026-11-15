/* New workflow V6319; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6319i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80 c6 $80;
gene='gene01';c1='46.13';c2='36.2';c3='11.270000000000001';c4='-12.659999999999998';c5='-22.59';c6='61.480000000000004';output;
gene='gene02';c1='0.26';c2='27.330000000000002';c3='16.400000000000002';c4='47.47';c5='-18.459999999999997';c6='41.61';output;
gene='gene03';c1='-12.61';c2='21.46';c3='29.53';c4='-26.4';c5='57.67';c6='-13.26';output;
gene='gene04';c1='23.52';c2='-5.41';c3='66.66';c4='30.73';c5='53.800000000000004';c6='65.86999999999999';output;
gene='gene05';c1='-29.35';c2='-6.279999999999999';c3='15.790000000000001';c4='34.86';c5='31.93';c6='62.0';output;
gene='gene06';c1='-2.2199999999999998';c2='44.85';c3='-8.08';c4='-26.009999999999998';c5='12.059999999999999';c6='37.13';output;
gene='gene07';c1='-13.09';c2='70.97999999999999';c3='-18.95';c4='-21.88';c5='71.19';c6='44.26';output;
gene='gene08';c1='-21.96';c2='17.11';c3='-0.82';c4='18.25';c5='-10.680000000000001';c6='-22.61';output;
run;
%n26_char2num_dsd(dsdin=v6319i,vars=c1,dsdout=v6319o);
data v6319m(keep=metric value);set v6319o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6319m;set v6319m;format value best32.;run;
proc export data=v6319m outfile="%sysfunc(pathname(work))/V6319.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6319;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6319:;quit;
