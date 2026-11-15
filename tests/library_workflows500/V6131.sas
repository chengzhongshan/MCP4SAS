/* New workflow V6131; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6131i;
length gene $80;
gene='gene01';c1=40.13;c2=21.2;c3=0.27;output;
gene='gene02';c1=70.26;c2=31.330000000000002;c3=32.4;output;
gene='gene03';c1=20.39;c2=6.46;c3=26.53;output;
gene='gene04';c1=4.52;c2=43.59;c3=59.660000000000004;output;
gene='gene05';c1=70.65;c2=-15.28;c3=-13.209999999999999;output;
gene='gene06';c1=-9.22;c2=67.85;c3=-3.0799999999999996;output;
gene='gene07';c1=-26.09;c2=51.98;c3=9.05;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6131i,Rgx=^(gene|c2)[[:space:]]*$,outdsd=v6131o,insensitive=1);
data v6131m(keep=metric value);set v6131o;length metric $120;array measured[*] c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6131o out=v6131s(keep=name type) noprint;run;data v6131s(keep=metric value);set v6131s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6131m data=v6131s;run;

data v6131m;set v6131m;format value best32.;run;
proc export data=v6131m outfile="%sysfunc(pathname(work))/V6131.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6131;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6131:;quit;
