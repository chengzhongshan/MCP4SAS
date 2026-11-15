/* New workflow V6061; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6061i;
length gene $80;
gene='gene01';c1=14.13;c2=55.2;c3=4.27;output;
gene='gene02';c1=51.26;c2=-24.669999999999998;c3=-0.6;output;
gene='gene03';c1=59.39;c2=64.46;c3=9.530000000000001;output;
gene='gene04';c1=36.52;c2=-8.41;c3=-26.34;output;
run;
%n26_Zscore4matrix(dsdin=v6061i,rowwide=0,ByVar4rowwide=gene,dsdout=v6061o);
data v6061m(keep=metric value);set v6061o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6061m;set v6061m;format value best32.;run;
proc export data=v6061m outfile="%sysfunc(pathname(work))/V6061.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6061;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6061:;quit;
