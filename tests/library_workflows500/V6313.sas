/* New workflow V6313; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6313i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80;
gene='gene01';c1='-12.87';c2='-8.799999999999999';c3='46.27';c4='35.34';c5='25.41';output;
gene='gene02';c1='0.26';c2='27.330000000000002';c3='-26.599999999999998';c4='31.470000000000002';c5='30.540000000000003';output;
gene='gene03';c1='-21.61';c2='70.46';c3='29.53';c4='-24.4';c5='38.67';output;
gene='gene04';c1='-18.48';c2='-27.41';c3='12.66';c4='19.73';c5='-9.200000000000001';output;
gene='gene05';c1='-13.35';c2='52.72';c3='11.790000000000001';c4='67.86';c5='-7.069999999999999';output;
gene='gene06';c1='-1.22';c2='23.85';c3='-3.0799999999999996';c4='-2.01';c5='50.06';output;
gene='gene07';c1='34.91';c2='-13.02';c3='-9.95';c4='71.11999999999999';c5='63.19';output;
gene='gene08';c1='0.040000000000000036';c2='10.11';c3='17.18';c4='22.25';c5='52.32';output;
gene='gene09';c1='-13.83';c2='24.240000000000002';c3='5.31';c4='12.38';c5='-9.55';output;
run;
%n26_char2num_dsd(dsdin=v6313i,vars=c1,dsdout=v6313o);
data v6313m(keep=metric value);set v6313o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6313m;set v6313m;format value best32.;run;
proc export data=v6313m outfile="%sysfunc(pathname(work))/V6313.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6313;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6313:;quit;
