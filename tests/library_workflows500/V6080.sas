/* New workflow V6080; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6080i;
length gene $80;
gene='gene01';c1=64.13;c2=-20.8;output;
gene='gene02';c1=66.26;c2=7.33;output;
gene='gene03';c1=-22.61;c2=62.46;output;
gene='gene04';c1=48.52;c2=-7.41;output;
gene='gene05';c1=-25.35;c2=22.72;output;
gene='gene06';c1=20.78;c2=51.85;output;
gene='gene07';c1=35.91;c2=19.98;output;
gene='gene08';c1=30.04;c2=-28.89;output;
gene='gene09';c1=59.17;c2=5.24;output;
run;
%n26_Zscore4matrix(dsdin=v6080i,rowwide=0,ByVar4rowwide=gene,dsdout=v6080o);
data v6080m(keep=metric value);set v6080o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6080m;set v6080m;format value best32.;run;
proc export data=v6080m outfile="%sysfunc(pathname(work))/V6080.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6080;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6080:;quit;
