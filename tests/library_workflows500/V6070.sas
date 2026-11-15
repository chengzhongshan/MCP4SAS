/* New workflow V6070; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6070i;
length gene $80;
gene='gene01';c1=-23.87;c2=24.2;output;
gene='gene02';c1=-12.74;c2=8.33;output;
gene='gene03';c1=0.39;c2=-19.54;output;
gene='gene04';c1=38.52;c2=-3.41;output;
gene='gene05';c1=-3.35;c2=60.72;output;
gene='gene06';c1=22.78;c2=27.85;output;
run;
%n26_Zscore4matrix(dsdin=v6070i,rowwide=0,ByVar4rowwide=gene,dsdout=v6070o);
data v6070m(keep=metric value);set v6070o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6070m;set v6070m;format value best32.;run;
proc export data=v6070m outfile="%sysfunc(pathname(work))/V6070.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6070;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6070:;quit;
