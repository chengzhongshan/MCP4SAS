/* New workflow V6071; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6071i;
length gene $80;
gene='gene01';c1=51.13;c2=-22.8;c3=55.27;output;
gene='gene02';c1=24.26;c2=29.330000000000002;c3=24.400000000000002;output;
gene='gene03';c1=13.39;c2=1.4600000000000002;c3=27.53;output;
gene='gene04';c1=40.52;c2=3.59;c3=60.660000000000004;output;
gene='gene05';c1=-14.35;c2=-5.279999999999999;c3=52.79;output;
gene='gene06';c1=-20.22;c2=12.85;c3=27.92;output;
gene='gene07';c1=43.91;c2=-16.02;c3=-12.95;output;
run;
%n26_Zscore4matrix(dsdin=v6071i,rowwide=0,ByVar4rowwide=gene,dsdout=v6071o);
data v6071m(keep=metric value);set v6071o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6071m;set v6071m;format value best32.;run;
proc export data=v6071m outfile="%sysfunc(pathname(work))/V6071.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6071;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6071:;quit;
