/* New workflow V6072; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6072i;
length gene $80;
gene='gene01';c1=-17.87;c2=53.2;c3=-16.73;c4=13.340000000000002;output;
gene='gene02';c1=23.26;c2=-12.67;c3=17.400000000000002;c4=31.470000000000002;output;
gene='gene03';c1=1.3900000000000001;c2=17.46;c3=-9.469999999999999;c4=65.6;output;
gene='gene04';c1=-11.48;c2=-2.41;c3=45.660000000000004;c4=60.730000000000004;output;
gene='gene05';c1=60.65;c2=-8.28;c3=28.79;c4=-23.14;output;
gene='gene06';c1=-14.22;c2=47.85;c3=41.92;c4=-2.01;output;
gene='gene07';c1=1.9100000000000001;c2=30.98;c3=36.05;c4=29.12;output;
gene='gene08';c1=-28.96;c2=-22.89;c3=-20.82;c4=56.25;output;
run;
%n26_Zscore4matrix(dsdin=v6072i,rowwide=0,ByVar4rowwide=gene,dsdout=v6072o);
data v6072m(keep=metric value);set v6072o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6072m;set v6072m;format value best32.;run;
proc export data=v6072m outfile="%sysfunc(pathname(work))/V6072.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6072;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6072:;quit;
