/* New workflow V6073; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6073i;
length gene $80;
gene='gene01';c1=-22.87;c2=47.2;c3=19.27;c4=-2.66;c5=42.410000000000004;output;
gene='gene02';c1=20.26;c2=59.33;c3=-24.599999999999998;c4=64.47;c5=5.54;output;
gene='gene03';c1=67.39;c2=51.46;c3=18.53;c4=-14.399999999999999;c5=-4.33;output;
gene='gene04';c1=9.52;c2=63.59;c3=20.66;c4=6.7299999999999995;c5=26.8;output;
gene='gene05';c1=31.65;c2=-7.279999999999999;c3=56.79;c4=-0.13999999999999996;c5=54.93;output;
gene='gene06';c1=29.78;c2=23.85;c3=30.92;c4=5.99;c5=-1.9399999999999997;output;
gene='gene07';c1=-11.09;c2=-26.02;c3=-8.95;c4=5.12;c5=31.19;output;
gene='gene08';c1=-4.96;c2=57.11;c3=49.18;c4=26.25;c5=31.32;output;
gene='gene09';c1=-23.83;c2=44.24;c3=10.31;c4=69.38;c5=37.45;output;
run;
%n26_Zscore4matrix(dsdin=v6073i,rowwide=0,ByVar4rowwide=gene,dsdout=v6073o);
data v6073m(keep=metric value);set v6073o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6073m;set v6073m;format value best32.;run;
proc export data=v6073m outfile="%sysfunc(pathname(work))/V6073.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6073;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6073:;quit;
