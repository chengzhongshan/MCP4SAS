/* New workflow V6339; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6339i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80 c6 $80;
gene='gene01';c1='5.13';c2='-11.799999999999999';c3='-1.73';c4='-26.66';c5='33.410000000000004';c6='-19.52';output;
gene='gene02';c1='69.26';c2='15.33';c3='24.400000000000002';c4='-2.5300000000000002';c5='-11.46';c6='10.61';output;
gene='gene03';c1='63.39';c2='10.46';c3='24.53';c4='55.6';c5='22.67';c6='-27.259999999999998';output;
gene='gene04';c1='1.52';c2='48.59';c3='32.660000000000004';c4='0.73';c5='20.8';c6='3.87';output;
gene='gene05';c1='-15.35';c2='22.72';c3='30.79';c4='19.86';c5='-14.07';c6='36.0';output;
gene='gene06';c1='38.78';c2='12.85';c3='-25.08';c4='60.99';c5='-1.9399999999999997';c6='0.13000000000000006';output;
gene='gene07';c1='68.91';c2='22.98';c3='27.05';c4='38.12';c5='-1.8099999999999998';c6='-23.74';output;
gene='gene08';c1='54.04';c2='9.11';c3='14.18';c4='-16.75';c5='-16.68';c6='-2.61';output;
run;
%n26_char2num_dsd(dsdin=v6339i,vars=c1 c2 c3,dsdout=v6339o);
data v6339m(keep=metric value);set v6339o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6339m;set v6339m;format value best32.;run;
proc export data=v6339m outfile="%sysfunc(pathname(work))/V6339.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6339;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6339:;quit;
