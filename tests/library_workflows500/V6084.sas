/* New workflow V6084; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6084i;
length gene $80;
gene='gene01';c1=43.13;c2=0.2;c3=69.27;c4=44.34;c5=13.41;c6=63.480000000000004;output;
gene='gene02';c1=-24.74;c2=57.33;c3=19.400000000000002;c4=54.47;c5=5.54;c6=49.61;output;
gene='gene03';c1=45.39;c2=-17.54;c3=22.53;c4=12.600000000000001;c5=-17.33;c6=53.74;output;
gene='gene04';c1=22.52;c2=57.59;c3=9.66;c4=-13.27;c5=-4.2;c6=-24.13;output;
gene='gene05';c1=46.65;c2=20.72;c3=12.790000000000001;c4=2.86;c5=-0.06999999999999995;c6=-11.0;output;
gene='gene06';c1=34.78;c2=19.85;c3=54.92;c4=24.990000000000002;c5=40.06;c6=-22.869999999999997;output;
gene='gene07';c1=26.91;c2=-2.02;c3=-13.95;c4=-4.88;c5=41.19;c6=3.2600000000000002;output;
run;
%n26_Zscore4matrix(dsdin=v6084i,rowwide=1,ByVar4rowwide=gene,dsdout=v6084o);
data v6084m(keep=metric value);set v6084o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6084m;set v6084m;format value best32.;run;
proc export data=v6084m outfile="%sysfunc(pathname(work))/V6084.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6084;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6084:;quit;
