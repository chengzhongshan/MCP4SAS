/* New workflow V6333; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6333i;
length gene $80 c1 $80 c2 $80 c3 $80 c4 $80 c5 $80;
gene='gene01';c1='29.13';c2='-15.799999999999999';c3='-23.73';c4='-21.66';c5='38.410000000000004';output;
gene='gene02';c1='70.26';c2='63.33';c3='48.4';c4='64.47';c5='68.54';output;
gene='gene03';c1='61.39';c2='-7.54';c3='3.5300000000000002';c4='-13.399999999999999';c5='0.67';output;
gene='gene04';c1='22.52';c2='-14.41';c3='6.659999999999999';c4='56.730000000000004';c5='-29.2';output;
gene='gene05';c1='30.65';c2='45.72';c3='59.79';c4='49.86';c5='62.93';output;
gene='gene06';c1='20.78';c2='-18.15';c3='-21.08';c4='46.99';c5='60.06';output;
gene='gene07';c1='2.91';c2='-24.02';c3='54.05';c4='13.120000000000001';c5='37.19';output;
gene='gene08';c1='-25.96';c2='0.11000000000000004';c3='-21.82';c4='46.25';c5='-4.68';output;
gene='gene09';c1='-17.83';c2='66.24';c3='0.30999999999999994';c4='39.38';c5='14.45';output;
run;
%n26_char2num_dsd(dsdin=v6333i,vars=c1 c2 c3,dsdout=v6333o);
data v6333m(keep=metric value);set v6333o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6333m;set v6333m;format value best32.;run;
proc export data=v6333m outfile="%sysfunc(pathname(work))/V6333.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6333;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6333:;quit;
