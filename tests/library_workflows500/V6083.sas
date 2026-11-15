/* New workflow V6083; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6083i;
length gene $80;
gene='gene01';c1=-6.87;c2=57.2;c3=-16.73;c4=40.34;c5=9.41;output;
gene='gene02';c1=-17.74;c2=16.330000000000002;c3=-18.599999999999998;c4=27.470000000000002;c5=-15.46;output;
gene='gene03';c1=3.39;c2=65.46;c3=38.53;c4=-24.4;c5=8.67;output;
gene='gene04';c1=61.52;c2=61.59;c3=56.660000000000004;c4=24.73;c5=67.8;output;
gene='gene05';c1=5.65;c2=3.7199999999999998;c3=32.79;c4=15.860000000000001;c5=-2.0700000000000003;output;
gene='gene06';c1=49.78;c2=52.85;c3=35.92;c4=59.99;c5=68.06;output;
run;
%n26_Zscore4matrix(dsdin=v6083i,rowwide=1,ByVar4rowwide=gene,dsdout=v6083o);
data v6083m(keep=metric value);set v6083o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6083m;set v6083m;format value best32.;run;
proc export data=v6083m outfile="%sysfunc(pathname(work))/V6083.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6083;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6083:;quit;
