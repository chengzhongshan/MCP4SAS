/* New workflow V6139; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6139i;
length gene $80;
gene='gene01';c1=-8.87;c2=-4.8;c3=26.27;c4=68.33999999999999;c5=63.410000000000004;c6=22.48;output;
gene='gene02';c1=40.26;c2=4.33;c3=40.4;c4=24.470000000000002;c5=0.54;c6=66.61;output;
gene='gene03';c1=-29.61;c2=35.46;c3=-20.47;c4=10.600000000000001;c5=0.67;c6=2.74;output;
gene='gene04';c1=34.52;c2=25.59;c3=19.66;c4=12.73;c5=-16.2;c6=26.87;output;
gene='gene05';c1=-5.35;c2=27.72;c3=0.79;c4=59.86;c5=-29.07;c6=27.0;output;
gene='gene06';c1=-8.22;c2=19.85;c3=37.92;c4=39.99;c5=38.06;c6=64.13;output;
gene='gene07';c1=61.91;c2=25.98;c3=63.05;c4=-28.88;c5=44.19;c6=-25.74;output;
gene='gene08';c1=-13.96;c2=50.11;c3=17.18;c4=46.25;c5=45.32;c6=52.39;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6139i,Rgx=^(gene|c2|c4|c6)[[:space:]]*$,outdsd=v6139o,insensitive=1);
data v6139m(keep=metric value);set v6139o;length metric $120;array measured[*] c2 c4 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6139o out=v6139s(keep=name type) noprint;run;data v6139s(keep=metric value);set v6139s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6139m data=v6139s;run;

data v6139m;set v6139m;format value best32.;run;
proc export data=v6139m outfile="%sysfunc(pathname(work))/V6139.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6139;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6139:;quit;
