/* New workflow V6089; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6089i;
length gene $80;
gene='gene01';c1=25.13;c2=-13.799999999999999;c3=5.27;c4=70.33999999999999;c5=31.41;c6=69.47999999999999;output;
gene='gene02';c1=-17.74;c2=61.33;c3=31.400000000000002;c4=15.47;c5=-28.459999999999997;c6=-25.389999999999997;output;
gene='gene03';c1=65.39;c2=30.46;c3=-27.47;c4=-22.4;c5=17.67;c6=-20.259999999999998;output;
gene='gene04';c1=31.52;c2=51.59;c3=13.66;c4=51.730000000000004;c5=8.799999999999999;c6=-24.13;output;
gene='gene05';c1=28.65;c2=13.72;c3=53.79;c4=36.86;c5=10.93;c6=15.0;output;
run;
%n26_Zscore4matrix(dsdin=v6089i,rowwide=1,ByVar4rowwide=gene,dsdout=v6089o);
data v6089m(keep=metric value);set v6089o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6089m;set v6089m;format value best32.;run;
proc export data=v6089m outfile="%sysfunc(pathname(work))/V6089.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6089;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6089:;quit;
