/* New workflow V6159; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6159i;
length gene $80;
gene='gene01';c1=4.13;c2=54.2;c3=46.27;c4=50.34;c5=12.41;c6=10.48;output;
gene='gene02';c1=68.26;c2=-25.669999999999998;c3=53.4;c4=-11.53;c5=30.540000000000003;c6=-20.389999999999997;output;
gene='gene03';c1=63.39;c2=32.46;c3=42.53;c4=35.6;c5=17.67;c6=7.739999999999999;output;
gene='gene04';c1=44.52;c2=70.58999999999999;c3=14.66;c4=46.730000000000004;c5=-10.200000000000001;c6=39.870000000000005;output;
gene='gene05';c1=-11.35;c2=52.72;c3=69.79;c4=-4.14;c5=36.93;c6=5.0;output;
gene='gene06';c1=54.78;c2=44.85;c3=1.92;c4=30.990000000000002;c5=-21.939999999999998;c6=2.13;output;
gene='gene07';c1=-24.09;c2=28.98;c3=27.05;c4=8.120000000000001;c5=-16.81;c6=-7.74;output;
gene='gene08';c1=40.04;c2=28.11;c3=5.18;c4=60.25;c5=-21.68;c6=17.39;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6159i,Rgx=^(c2|c4|c6)[[:space:]]*$,outdsd=v6159o);
data v6159m(keep=metric value);set v6159o;length metric $120;array measured[*] c1 c3 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6159o out=v6159s(keep=name type) noprint;run;data v6159s(keep=metric value);set v6159s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6159m data=v6159s;run;

data v6159m;set v6159m;format value best32.;run;
proc export data=v6159m outfile="%sysfunc(pathname(work))/V6159.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6159;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6159:;quit;
