/* New workflow V6087; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6087i;
length gene $80;
gene='gene01';c1=-19.87;c2=38.2;c3=70.27;c4=6.34;output;
gene='gene02';c1=24.26;c2=5.33;c3=-21.599999999999998;c4=24.470000000000002;output;
gene='gene03';c1=19.39;c2=-11.54;c3=6.529999999999999;c4=55.6;output;
run;
%n26_Zscore4matrix(dsdin=v6087i,rowwide=1,ByVar4rowwide=gene,dsdout=v6087o);
data v6087m(keep=metric value);set v6087o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6087m;set v6087m;format value best32.;run;
proc export data=v6087m outfile="%sysfunc(pathname(work))/V6087.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6087;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6087:;quit;
