/* New workflow V6064; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6064i;
length gene $80;
gene='gene01';c1=70.13;c2=-19.8;c3=-18.73;c4=-0.6599999999999999;c5=46.410000000000004;c6=3.48;output;
gene='gene02';c1=15.26;c2=-10.67;c3=47.4;c4=69.47;c5=54.54;c6=37.61;output;
gene='gene03';c1=63.39;c2=-26.54;c3=-1.4699999999999998;c4=-7.4;c5=-12.33;c6=68.74;output;
gene='gene04';c1=12.52;c2=-4.41;c3=-11.34;c4=41.730000000000004;c5=-18.2;c6=66.86999999999999;output;
gene='gene05';c1=50.65;c2=0.72;c3=-11.209999999999999;c4=32.86;c5=-28.07;c6=13.0;output;
gene='gene06';c1=51.78;c2=3.85;c3=27.92;c4=34.99;c5=54.06;c6=-5.87;output;
gene='gene07';c1=67.91;c2=-19.02;c3=58.05;c4=64.11999999999999;c5=1.19;c6=-1.7399999999999998;output;
run;
%n26_Zscore4matrix(dsdin=v6064i,rowwide=0,ByVar4rowwide=gene,dsdout=v6064o);
data v6064m(keep=metric value);set v6064o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6064m;set v6064m;format value best32.;run;
proc export data=v6064m outfile="%sysfunc(pathname(work))/V6064.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6064;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6064:;quit;
