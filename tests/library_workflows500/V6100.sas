/* New workflow V6100; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6100i;
length gene $80;
gene='gene01';c1=69.13;c2=-12.799999999999999;output;
gene='gene02';c1=68.26;c2=47.33;output;
gene='gene03';c1=60.39;c2=48.46;output;
gene='gene04';c1=42.52;c2=51.59;output;
gene='gene05';c1=-9.35;c2=35.72;output;
gene='gene06';c1=9.78;c2=43.85;output;
gene='gene07';c1=29.91;c2=-8.02;output;
gene='gene08';c1=-4.96;c2=-20.89;output;
gene='gene09';c1=-25.83;c2=54.24;output;
run;
%n26_Zscore4matrix(dsdin=v6100i,rowwide=1,ByVar4rowwide=gene,dsdout=v6100o);
data v6100m(keep=metric value);set v6100o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6100m;set v6100m;format value best32.;run;
proc export data=v6100m outfile="%sysfunc(pathname(work))/V6100.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6100;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6100:;quit;
