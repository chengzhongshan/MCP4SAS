/* New workflow V6086; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6086i;
length gene $80;
gene='gene01';c1=12.13;c2=-17.8;c3=-29.73;output;
gene='gene02';c1=52.26;c2=-11.67;c3=0.4;output;
gene='gene03';c1=0.39;c2=11.46;c3=69.53;output;
gene='gene04';c1=-12.48;c2=5.59;c3=59.660000000000004;output;
gene='gene05';c1=35.65;c2=26.72;c3=27.79;output;
gene='gene06';c1=49.78;c2=63.85;c3=35.92;output;
gene='gene07';c1=20.91;c2=16.98;c3=53.05;output;
gene='gene08';c1=65.04;c2=63.11;c3=32.18;output;
gene='gene09';c1=10.17;c2=-3.7600000000000002;c3=-18.689999999999998;output;
run;
%n26_Zscore4matrix(dsdin=v6086i,rowwide=1,ByVar4rowwide=gene,dsdout=v6086o);
data v6086m(keep=metric value);set v6086o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6086m;set v6086m;format value best32.;run;
proc export data=v6086m outfile="%sysfunc(pathname(work))/V6086.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6086;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6086:;quit;
