/* New workflow V6092; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6092i;
length gene $80;
gene='gene01';c1=24.13;c2=-5.8;c3=46.27;c4=44.34;output;
gene='gene02';c1=0.26;c2=26.330000000000002;c3=61.4;c4=-16.529999999999998;output;
gene='gene03';c1=-0.61;c2=46.46;c3=48.53;c4=-11.399999999999999;output;
gene='gene04';c1=-15.48;c2=44.59;c3=16.66;c4=52.730000000000004;output;
gene='gene05';c1=-0.35;c2=55.72;c3=37.79;c4=40.86;output;
gene='gene06';c1=62.78;c2=6.8500000000000005;c3=37.92;c4=69.99;output;
gene='gene07';c1=-17.09;c2=10.98;c3=53.05;c4=29.12;output;
gene='gene08';c1=17.04;c2=-18.89;c3=19.18;c4=66.25;output;
run;
%n26_Zscore4matrix(dsdin=v6092i,rowwide=1,ByVar4rowwide=gene,dsdout=v6092o);
data v6092m(keep=metric value);set v6092o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6092m;set v6092m;format value best32.;run;
proc export data=v6092m outfile="%sysfunc(pathname(work))/V6092.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6092;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6092:;quit;
