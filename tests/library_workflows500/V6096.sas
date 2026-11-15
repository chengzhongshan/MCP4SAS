/* New workflow V6096; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6096i;
length gene $80;
gene='gene01';c1=5.13;c2=-12.799999999999999;c3=-26.73;output;
gene='gene02';c1=17.26;c2=50.33;c3=45.4;output;
gene='gene03';c1=28.39;c2=30.46;c3=26.53;output;
gene='gene04';c1=36.52;c2=0.5900000000000001;c3=1.6600000000000001;output;
gene='gene05';c1=-7.35;c2=-22.28;c3=18.79;output;
run;
%n26_Zscore4matrix(dsdin=v6096i,rowwide=1,ByVar4rowwide=gene,dsdout=v6096o);
data v6096m(keep=metric value);set v6096o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6096m;set v6096m;format value best32.;run;
proc export data=v6096m outfile="%sysfunc(pathname(work))/V6096.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6096;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6096:;quit;
