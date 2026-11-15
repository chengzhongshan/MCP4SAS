/* New workflow V6093; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6093i;
length gene $80;
gene='gene01';c1=43.13;c2=55.2;c3=-6.73;c4=23.34;c5=29.41;output;
gene='gene02';c1=15.26;c2=-14.67;c3=66.4;c4=44.47;c5=-10.46;output;
gene='gene03';c1=55.39;c2=55.46;c3=15.530000000000001;c4=-0.39999999999999997;c5=-6.33;output;
gene='gene04';c1=9.52;c2=16.59;c3=20.66;c4=52.730000000000004;c5=-8.200000000000001;output;
gene='gene05';c1=32.65;c2=34.72;c3=4.79;c4=24.86;c5=34.93;output;
gene='gene06';c1=67.78;c2=-24.15;c3=-23.08;c4=67.99;c5=55.06;output;
gene='gene07';c1=69.91;c2=20.98;c3=49.05;c4=45.12;c5=-18.81;output;
gene='gene08';c1=14.04;c2=0.11000000000000004;c3=54.18;c4=0.25000000000000006;c5=-19.68;output;
gene='gene09';c1=1.17;c2=50.24;c3=-19.689999999999998;c4=27.380000000000003;c5=-1.55;output;
run;
%n26_Zscore4matrix(dsdin=v6093i,rowwide=1,ByVar4rowwide=gene,dsdout=v6093o);
data v6093m(keep=metric value);set v6093o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6093m;set v6093m;format value best32.;run;
proc export data=v6093m outfile="%sysfunc(pathname(work))/V6093.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6093;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6093:;quit;
