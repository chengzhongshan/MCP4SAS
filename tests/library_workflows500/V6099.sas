/* New workflow V6099; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6099i;
length gene $80;
gene='gene01';c1=58.13;c2=60.2;c3=46.27;c4=-6.66;c5=-6.59;c6=13.48;output;
gene='gene02';c1=14.26;c2=-23.669999999999998;c3=57.4;c4=26.470000000000002;c5=58.54;c6=43.61;output;
gene='gene03';c1=34.39;c2=12.46;c3=46.53;c4=-10.399999999999999;c5=43.67;c6=7.739999999999999;output;
gene='gene04';c1=-12.48;c2=8.59;c3=-15.34;c4=58.730000000000004;c5=49.800000000000004;c6=19.87;output;
gene='gene05';c1=33.65;c2=19.72;c3=-21.21;c4=55.86;c5=17.93;c6=-11.0;output;
gene='gene06';c1=65.78;c2=5.8500000000000005;c3=63.92;c4=-24.009999999999998;c5=68.06;c6=51.13;output;
gene='gene07';c1=16.91;c2=38.98;c3=-16.95;c4=46.12;c5=-7.81;c6=-4.74;output;
gene='gene08';c1=50.04;c2=23.11;c3=-2.82;c4=49.25;c5=-21.68;c6=20.39;output;
run;
%n26_Zscore4matrix(dsdin=v6099i,rowwide=1,ByVar4rowwide=gene,dsdout=v6099o);
data v6099m(keep=metric value);set v6099o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6099m;set v6099m;format value best32.;run;
proc export data=v6099m outfile="%sysfunc(pathname(work))/V6099.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6099;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6099:;quit;
