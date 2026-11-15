/* New workflow V6328; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6328i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80;
gene='gene01';c1='4.13';c2='7.2';c3='33.27';c4='-15.659999999999998';c5='-20.59';output;
gene='gene02';c1='52.26';c2='-5.67';c3='-10.6';c4='53.47';c5='59.54';output;
gene='gene03';c1='-25.61';c2='12.46';c3='-9.469999999999999';c4='-4.4';c5='48.67';output;
gene='gene04';c1='-16.48';c2='53.59';c3='30.66';c4='-18.27';c5='68.8';output;
run;
%n26_char2num_dsd(dsdin=v6328i,vars=c1 c2 c3,dsdout=v6328o);
data v6328m(keep=metric value);set v6328o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6328m;set v6328m;format value best32.;run;
proc export data=v6328m outfile="%sysfunc(pathname(work))/V6328.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6328;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6328:;quit;
