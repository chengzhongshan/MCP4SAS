/* New workflow V6091; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6091i;
length gene $80;
gene='gene01';c1=-26.87;c2=69.19999999999999;c3=36.27;output;
gene='gene02';c1=-6.74;c2=41.33;c3=20.400000000000002;output;
gene='gene03';c1=-3.61;c2=7.46;c3=34.53;output;
gene='gene04';c1=-21.48;c2=-18.41;c3=-12.34;output;
gene='gene05';c1=-0.35;c2=-28.28;c3=2.79;output;
gene='gene06';c1=50.78;c2=8.85;c3=4.92;output;
gene='gene07';c1=67.91;c2=-18.02;c3=22.05;output;
run;
%n26_Zscore4matrix(dsdin=v6091i,rowwide=1,ByVar4rowwide=gene,dsdout=v6091o);
data v6091m(keep=metric value);set v6091o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6091m;set v6091m;format value best32.;run;
proc export data=v6091m outfile="%sysfunc(pathname(work))/V6091.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6091;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6091:;quit;
