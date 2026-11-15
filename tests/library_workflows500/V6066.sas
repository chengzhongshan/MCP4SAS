/* New workflow V6066; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6066i;
length gene $80;
gene='gene01';c1=-6.87;c2=59.2;c3=-1.73;output;
gene='gene02';c1=68.26;c2=62.33;c3=62.4;output;
gene='gene03';c1=1.3900000000000001;c2=-4.54;c3=-29.47;output;
gene='gene04';c1=29.52;c2=60.59;c3=-13.34;output;
gene='gene05';c1=59.65;c2=14.72;c3=24.79;output;
gene='gene06';c1=-17.22;c2=4.8500000000000005;c3=15.92;output;
gene='gene07';c1=70.91;c2=24.98;c3=-18.95;output;
gene='gene08';c1=2.04;c2=12.11;c3=-14.82;output;
gene='gene09';c1=19.17;c2=-10.76;c3=-6.69;output;
run;
%n26_Zscore4matrix(dsdin=v6066i,rowwide=0,ByVar4rowwide=gene,dsdout=v6066o);
data v6066m(keep=metric value);set v6066o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6066m;set v6066m;format value best32.;run;
proc export data=v6066m outfile="%sysfunc(pathname(work))/V6066.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6066;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6066:;quit;
