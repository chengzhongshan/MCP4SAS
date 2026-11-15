/* New workflow V6063; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6063i;
length gene $80;
gene='gene01';c1=17.13;c2=27.2;c3=17.27;c4=8.340000000000002;c5=66.41;output;
gene='gene02';c1=-29.74;c2=-11.67;c3=3.4;c4=20.470000000000002;c5=62.54;output;
gene='gene03';c1=56.39;c2=54.46;c3=-22.47;c4=10.600000000000001;c5=2.67;output;
gene='gene04';c1=29.52;c2=22.59;c3=66.66;c4=38.730000000000004;c5=-3.2;output;
gene='gene05';c1=28.65;c2=14.72;c3=52.79;c4=44.86;c5=-20.07;output;
gene='gene06';c1=39.78;c2=26.85;c3=-23.08;c4=7.99;c5=55.06;output;
run;
%n26_Zscore4matrix(dsdin=v6063i,rowwide=0,ByVar4rowwide=gene,dsdout=v6063o);
data v6063m(keep=metric value);set v6063o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6063m;set v6063m;format value best32.;run;
proc export data=v6063m outfile="%sysfunc(pathname(work))/V6063.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6063;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6063:;quit;
