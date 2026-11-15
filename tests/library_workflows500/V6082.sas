/* New workflow V6082; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6082i;
length gene $80;
gene='gene01';c1=9.13;c2=13.200000000000001;c3=3.27;c4=34.34;output;
gene='gene02';c1=-2.74;c2=9.33;c3=59.4;c4=-16.529999999999998;output;
gene='gene03';c1=-22.61;c2=32.46;c3=5.529999999999999;c4=-28.4;output;
gene='gene04';c1=-29.48;c2=-2.41;c3=-17.34;c4=52.730000000000004;output;
gene='gene05';c1=42.65;c2=-21.28;c3=25.79;c4=64.86;output;
run;
%n26_Zscore4matrix(dsdin=v6082i,rowwide=1,ByVar4rowwide=gene,dsdout=v6082o);
data v6082m(keep=metric value);set v6082o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6082m;set v6082m;format value best32.;run;
proc export data=v6082m outfile="%sysfunc(pathname(work))/V6082.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6082;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6082:;quit;
