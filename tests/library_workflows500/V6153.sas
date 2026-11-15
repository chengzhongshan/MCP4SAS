/* New workflow V6153; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6153i;
length gene $80;
gene='gene01';c1=42.13;c2=46.2;c3=45.27;c4=0.34;c5=-8.59;output;
gene='gene02';c1=35.26;c2=59.33;c3=7.3999999999999995;c4=-14.53;c5=0.54;output;
gene='gene03';c1=-9.61;c2=62.46;c3=-24.47;c4=42.6;c5=33.67;output;
gene='gene04';c1=51.52;c2=-24.41;c3=40.660000000000004;c4=-14.27;c5=38.800000000000004;output;
gene='gene05';c1=25.65;c2=38.72;c3=-26.21;c4=20.86;c5=-16.07;output;
gene='gene06';c1=-29.22;c2=62.85;c3=-3.0799999999999996;c4=-2.01;c5=68.06;output;
gene='gene07';c1=24.91;c2=36.98;c3=20.05;c4=32.12;c5=66.19;output;
gene='gene08';c1=18.04;c2=-2.89;c3=-10.82;c4=64.25;c5=-9.680000000000001;output;
gene='gene09';c1=54.17;c2=64.24;c3=49.31;c4=1.38;c5=12.45;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6153i,Rgx=^(c2|c4)[[:space:]]*$,outdsd=v6153o);
data v6153m(keep=metric value);set v6153o;length metric $120;array measured[*] c1 c3 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6153o out=v6153s(keep=name type) noprint;run;data v6153s(keep=metric value);set v6153s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6153m data=v6153s;run;

data v6153m;set v6153m;format value best32.;run;
proc export data=v6153m outfile="%sysfunc(pathname(work))/V6153.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6153;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6153:;quit;
