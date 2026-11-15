/* New workflow V6144; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6144i;
length gene $80;
gene='gene01';c1=25.13;c2=23.2;c3=27.27;c4=29.34;c5=32.410000000000004;c6=68.47999999999999;output;
gene='gene02';c1=65.26;c2=-10.67;c3=-4.6000000000000005;c4=6.47;c5=7.54;c6=19.610000000000003;output;
gene='gene03';c1=38.39;c2=56.46;c3=46.53;c4=61.6;c5=53.67;c6=57.74;output;
gene='gene04';c1=-14.48;c2=6.59;c3=10.66;c4=45.730000000000004;c5=-17.2;c6=40.870000000000005;output;
gene='gene05';c1=-26.35;c2=-14.28;c3=42.79;c4=19.86;c5=55.93;c6=-7.0;output;
gene='gene06';c1=58.78;c2=53.85;c3=-1.08;c4=59.99;c5=-24.939999999999998;c6=68.13;output;
gene='gene07';c1=44.91;c2=64.97999999999999;c3=-11.95;c4=5.12;c5=5.19;c6=68.25999999999999;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6144i,Rgx=^(c1|c3|c5)[[:space:]]*$,outdsd=v6144o);
data v6144m(keep=metric value);set v6144o;length metric $120;array measured[*] c2 c4 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6144o out=v6144s(keep=name type) noprint;run;data v6144s(keep=metric value);set v6144s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6144m data=v6144s;run;

data v6144m;set v6144m;format value best32.;run;
proc export data=v6144m outfile="%sysfunc(pathname(work))/V6144.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6144;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6144:;quit;
