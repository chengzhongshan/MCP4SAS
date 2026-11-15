/* New workflow V6075; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6075i;
length gene $80;
gene='gene01';c1=-16.87;c2=45.2;output;
gene='gene02';c1=44.26;c2=31.330000000000002;output;
gene='gene03';c1=31.39;c2=70.46;output;
gene='gene04';c1=28.52;c2=36.59;output;
run;
%n26_Zscore4matrix(dsdin=v6075i,rowwide=0,ByVar4rowwide=gene,dsdout=v6075o);
data v6075m(keep=metric value);set v6075o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6075m;set v6075m;format value best32.;run;
proc export data=v6075m outfile="%sysfunc(pathname(work))/V6075.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6075;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6075:;quit;
