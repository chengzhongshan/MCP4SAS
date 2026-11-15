/* New workflow V6069; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6069i;
length gene $80;
gene='gene01';c1=48.13;c2=37.2;c3=20.27;c4=-12.659999999999998;c5=32.410000000000004;c6=27.48;output;
gene='gene02';c1=30.26;c2=44.33;c3=68.4;c4=11.47;c5=3.54;c6=51.61;output;
gene='gene03';c1=-21.61;c2=2.46;c3=-4.470000000000001;c4=6.6;c5=-18.33;c6=27.740000000000002;output;
gene='gene04';c1=58.52;c2=-14.41;c3=55.660000000000004;c4=-4.2700000000000005;c5=34.800000000000004;c6=17.87;output;
gene='gene05';c1=29.65;c2=27.72;c3=37.79;c4=33.86;c5=13.93;c6=1.0;output;
run;
%n26_Zscore4matrix(dsdin=v6069i,rowwide=0,ByVar4rowwide=gene,dsdout=v6069o);
data v6069m(keep=metric value);set v6069o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6069m;set v6069m;format value best32.;run;
proc export data=v6069m outfile="%sysfunc(pathname(work))/V6069.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6069;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6069:;quit;
