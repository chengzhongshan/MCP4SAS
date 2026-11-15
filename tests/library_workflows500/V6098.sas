/* New workflow V6098; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6098i;
length gene $80;
gene='gene01';c1=0.13;c2=28.2;c3=58.27;c4=-2.66;c5=14.41;output;
gene='gene02';c1=64.26;c2=-24.669999999999998;c3=26.400000000000002;c4=26.470000000000002;c5=-27.459999999999997;output;
gene='gene03';c1=56.39;c2=54.46;c3=-13.469999999999999;c4=23.6;c5=59.67;output;
gene='gene04';c1=-10.48;c2=1.59;c3=39.660000000000004;c4=14.73;c5=42.800000000000004;output;
gene='gene05';c1=39.65;c2=61.72;c3=-2.21;c4=45.86;c5=-1.07;output;
gene='gene06';c1=-25.22;c2=-5.1499999999999995;c3=4.92;c4=54.99;c5=7.0600000000000005;output;
gene='gene07';c1=-16.09;c2=-9.02;c3=-2.9499999999999997;c4=-9.879999999999999;c5=50.19;output;
run;
%n26_Zscore4matrix(dsdin=v6098i,rowwide=1,ByVar4rowwide=gene,dsdout=v6098o);
data v6098m(keep=metric value);set v6098o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6098m;set v6098m;format value best32.;run;
proc export data=v6098m outfile="%sysfunc(pathname(work))/V6098.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6098;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6098:;quit;
