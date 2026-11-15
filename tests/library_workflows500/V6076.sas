/* New workflow V6076; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6076i;
length gene $80;
gene='gene01';c1=36.13;c2=68.19999999999999;c3=14.270000000000001;output;
gene='gene02';c1=-26.74;c2=8.33;c3=47.4;output;
gene='gene03';c1=37.39;c2=-27.54;c3=-19.47;output;
gene='gene04';c1=-22.48;c2=51.59;c3=29.66;output;
gene='gene05';c1=-11.35;c2=50.72;c3=-10.209999999999999;output;
run;
%n26_Zscore4matrix(dsdin=v6076i,rowwide=0,ByVar4rowwide=gene,dsdout=v6076o);
data v6076m(keep=metric value);set v6076o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6076m;set v6076m;format value best32.;run;
proc export data=v6076m outfile="%sysfunc(pathname(work))/V6076.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6076;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6076:;quit;
