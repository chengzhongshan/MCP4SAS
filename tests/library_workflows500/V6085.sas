/* New workflow V6085; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6085i;
length gene $80;
gene='gene01';c1=-5.87;c2=58.2;output;
gene='gene02';c1=33.26;c2=4.33;output;
gene='gene03';c1=42.39;c2=-2.54;output;
gene='gene04';c1=51.52;c2=69.58999999999999;output;
gene='gene05';c1=69.65;c2=2.7199999999999998;output;
gene='gene06';c1=3.7800000000000002;c2=60.85;output;
gene='gene07';c1=7.91;c2=-1.0199999999999998;output;
gene='gene08';c1=26.04;c2=-28.89;output;
run;
%n26_Zscore4matrix(dsdin=v6085i,rowwide=1,ByVar4rowwide=gene,dsdout=v6085o);
data v6085m(keep=metric value);set v6085o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6085m;set v6085m;format value best32.;run;
proc export data=v6085m outfile="%sysfunc(pathname(work))/V6085.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6085;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6085:;quit;
