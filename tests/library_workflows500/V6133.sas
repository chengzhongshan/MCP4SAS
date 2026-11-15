/* New workflow V6133; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6133i;
length gene $80;
gene='gene01';c1=55.13;c2=15.200000000000001;c3=37.27;c4=-15.659999999999998;c5=-27.59;output;
gene='gene02';c1=17.26;c2=12.33;c3=37.4;c4=64.47;c5=36.54;output;
gene='gene03';c1=31.39;c2=45.46;c3=67.53;c4=-4.4;c5=16.67;output;
gene='gene04';c1=10.52;c2=-14.41;c3=59.660000000000004;c4=48.730000000000004;c5=17.8;output;
gene='gene05';c1=26.65;c2=13.72;c3=-4.21;c4=58.86;c5=13.93;output;
gene='gene06';c1=60.78;c2=-13.15;c3=3.9200000000000004;c4=56.99;c5=-24.939999999999998;output;
gene='gene07';c1=-4.09;c2=69.97999999999999;c3=32.05;c4=6.12;c5=-12.81;output;
gene='gene08';c1=32.04;c2=38.11;c3=39.18;c4=26.25;c5=39.32;output;
gene='gene09';c1=11.17;c2=44.24;c3=10.31;c4=-8.62;c5=52.45;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6133i,Rgx=^(gene|c2|c4)[[:space:]]*$,outdsd=v6133o,insensitive=1);
data v6133m(keep=metric value);set v6133o;length metric $120;array measured[*] c2 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6133o out=v6133s(keep=name type) noprint;run;data v6133s(keep=metric value);set v6133s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6133m data=v6133s;run;

data v6133m;set v6133m;format value best32.;run;
proc export data=v6133m outfile="%sysfunc(pathname(work))/V6133.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6133;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6133:;quit;
