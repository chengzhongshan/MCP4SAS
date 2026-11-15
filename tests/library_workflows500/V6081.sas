/* New workflow V6081; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6081i;
length gene $80;
gene='gene01';c1=29.13;c2=15.200000000000001;c3=21.27;output;
gene='gene02';c1=4.26;c2=55.33;c3=38.4;output;
gene='gene03';c1=44.39;c2=-22.54;c3=-10.469999999999999;output;
gene='gene04';c1=13.52;c2=66.58999999999999;c3=70.66;output;
run;
%n26_Zscore4matrix(dsdin=v6081i,rowwide=1,ByVar4rowwide=gene,dsdout=v6081o);
data v6081m(keep=metric value);set v6081o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6081m;set v6081m;format value best32.;run;
proc export data=v6081m outfile="%sysfunc(pathname(work))/V6081.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6081;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6081:;quit;
