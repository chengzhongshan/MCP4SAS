/* New workflow V6079; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6079i;
length gene $80;
gene='gene01';c1=-12.87;c2=13.200000000000001;c3=-24.73;c4=2.34;c5=34.410000000000004;c6=61.480000000000004;output;
gene='gene02';c1=35.26;c2=5.33;c3=-10.6;c4=-4.53;c5=28.540000000000003;c6=58.61;output;
gene='gene03';c1=-27.61;c2=25.46;c3=1.5300000000000002;c4=8.600000000000001;c5=-26.33;c6=8.74;output;
gene='gene04';c1=7.52;c2=18.59;c3=52.660000000000004;c4=-11.27;c5=20.8;c6=26.87;output;
gene='gene05';c1=-4.35;c2=-11.28;c3=-8.209999999999999;c4=19.86;c5=31.93;c6=3.0;output;
gene='gene06';c1=47.78;c2=23.85;c3=67.92;c4=10.99;c5=-0.94;c6=8.13;output;
gene='gene07';c1=-14.09;c2=21.98;c3=69.05;c4=-3.88;c5=28.19;c6=-1.7399999999999998;output;
gene='gene08';c1=65.04;c2=-19.89;c3=46.18;c4=38.25;c5=61.32;c6=0.39000000000000007;output;
run;
%n26_Zscore4matrix(dsdin=v6079i,rowwide=0,ByVar4rowwide=gene,dsdout=v6079o);
data v6079m(keep=metric value);set v6079o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6079m;set v6079m;format value best32.;run;
proc export data=v6079m outfile="%sysfunc(pathname(work))/V6079.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6079;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6079:;quit;
