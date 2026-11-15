/* New workflow V6067; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6067i;
length gene $80;
gene='gene01';c1=31.13;c2=-22.8;c3=11.270000000000001;c4=51.34;output;
gene='gene02';c1=66.26;c2=24.330000000000002;c3=-9.6;c4=-0.53;output;
gene='gene03';c1=49.39;c2=-21.54;c3=51.53;c4=47.6;output;
run;
%n26_Zscore4matrix(dsdin=v6067i,rowwide=0,ByVar4rowwide=gene,dsdout=v6067o);
data v6067m(keep=metric value);set v6067o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6067m;set v6067m;format value best32.;run;
proc export data=v6067m outfile="%sysfunc(pathname(work))/V6067.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6067;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6067:;quit;
