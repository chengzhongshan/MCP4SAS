/* New workflow V6124; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6124i;
length gene $80;
gene='gene01';c1=-3.87;c2=-14.799999999999999;c3=-24.73;c4=9.340000000000002;c5=7.41;c6=5.4799999999999995;output;
gene='gene02';c1=16.26;c2=6.33;c3=31.400000000000002;c4=-19.529999999999998;c5=56.54;c6=36.61;output;
gene='gene03';c1=58.39;c2=-11.54;c3=-13.469999999999999;c4=-0.39999999999999997;c5=-9.33;c6=17.740000000000002;output;
gene='gene04';c1=8.52;c2=63.59;c3=-18.34;c4=3.73;c5=64.8;c6=-13.13;output;
gene='gene05';c1=40.65;c2=-3.2800000000000002;c3=-26.21;c4=2.86;c5=69.93;c6=69.0;output;
gene='gene06';c1=60.78;c2=36.85;c3=19.92;c4=25.990000000000002;c5=63.06;c6=-2.8699999999999997;output;
gene='gene07';c1=-13.09;c2=45.98;c3=37.05;c4=48.12;c5=69.19;c6=27.26;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6124i,Rgx=^(gene|c1|c3|c5)[[:space:]]*$,outdsd=v6124o,insensitive=1);
data v6124m(keep=metric value);set v6124o;length metric $120;array measured[*] c1 c3 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6124o out=v6124s(keep=name type) noprint;run;data v6124s(keep=metric value);set v6124s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6124m data=v6124s;run;

data v6124m;set v6124m;format value best32.;run;
proc export data=v6124m outfile="%sysfunc(pathname(work))/V6124.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6124;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6124:;quit;
