/* New workflow V6158; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6158i;
length gene $80;
gene='gene01';c1=0.13;c2=46.2;c3=49.27;c4=15.340000000000002;c5=33.410000000000004;output;
gene='gene02';c1=31.26;c2=-13.67;c3=3.4;c4=27.470000000000002;c5=4.54;output;
gene='gene03';c1=-9.61;c2=5.46;c3=1.5300000000000002;c4=7.6;c5=44.67;output;
gene='gene04';c1=35.52;c2=-17.41;c3=57.660000000000004;c4=-5.2700000000000005;c5=23.8;output;
gene='gene05';c1=-29.35;c2=62.72;c3=58.79;c4=4.86;c5=-22.07;output;
gene='gene06';c1=19.78;c2=58.85;c3=42.92;c4=-13.01;c5=71.06;output;
gene='gene07';c1=24.91;c2=26.98;c3=34.05;c4=11.120000000000001;c5=28.19;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6158i,Rgx=^(c1|c3|c5)[[:space:]]*$,outdsd=v6158o);
data v6158m(keep=metric value);set v6158o;length metric $120;array measured[*] c2 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6158o out=v6158s(keep=name type) noprint;run;data v6158s(keep=metric value);set v6158s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6158m data=v6158s;run;

data v6158m;set v6158m;format value best32.;run;
proc export data=v6158m outfile="%sysfunc(pathname(work))/V6158.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6158;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6158:;quit;
