/* New workflow V6065; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6065i;
length gene $80;
gene='gene01';c1=63.13;c2=44.2;output;
gene='gene02';c1=-8.74;c2=-9.67;output;
gene='gene03';c1=8.39;c2=45.46;output;
gene='gene04';c1=30.52;c2=16.59;output;
gene='gene05';c1=22.65;c2=67.72;output;
gene='gene06';c1=-21.22;c2=45.85;output;
gene='gene07';c1=14.91;c2=-4.02;output;
gene='gene08';c1=-7.96;c2=62.11;output;
run;
%n26_Zscore4matrix(dsdin=v6065i,rowwide=0,ByVar4rowwide=gene,dsdout=v6065o);
data v6065m(keep=metric value);set v6065o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6065m;set v6065m;format value best32.;run;
proc export data=v6065m outfile="%sysfunc(pathname(work))/V6065.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6065;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6065:;quit;
