/* New workflow V6097; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6097i;
length gene $80;
gene='gene01';c1=17.13;c2=55.2;c3=35.27;c4=-3.66;output;
gene='gene02';c1=-27.74;c2=17.330000000000002;c3=50.4;c4=10.47;output;
gene='gene03';c1=36.39;c2=26.46;c3=10.530000000000001;c4=7.6;output;
gene='gene04';c1=10.52;c2=45.59;c3=-9.34;c4=32.730000000000004;output;
gene='gene05';c1=53.65;c2=4.720000000000001;c3=-17.21;c4=-21.14;output;
gene='gene06';c1=-14.22;c2=56.85;c3=-20.08;c4=-4.01;output;
run;
%n26_Zscore4matrix(dsdin=v6097i,rowwide=1,ByVar4rowwide=gene,dsdout=v6097o);
data v6097m(keep=metric value);set v6097o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6097m;set v6097m;format value best32.;run;
proc export data=v6097m outfile="%sysfunc(pathname(work))/V6097.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6097;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6097:;quit;
