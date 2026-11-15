/* New workflow V6088; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6088i;
length gene $80;
gene='gene01';c1=-20.87;c2=53.2;c3=57.27;c4=61.34;c5=65.41;output;
gene='gene02';c1=8.26;c2=53.33;c3=52.4;c4=-19.529999999999998;c5=-9.46;output;
gene='gene03';c1=-23.61;c2=40.46;c3=5.529999999999999;c4=0.6000000000000001;c5=41.67;output;
gene='gene04';c1=42.52;c2=45.59;c3=-10.34;c4=-15.27;c5=36.800000000000004;output;
run;
%n26_Zscore4matrix(dsdin=v6088i,rowwide=1,ByVar4rowwide=gene,dsdout=v6088o);
data v6088m(keep=metric value);set v6088o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6088m;set v6088m;format value best32.;run;
proc export data=v6088m outfile="%sysfunc(pathname(work))/V6088.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6088;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6088:;quit;
