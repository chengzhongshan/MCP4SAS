/* New workflow V6137; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6137i;
length gene $80;
gene='gene01';c1=60.13;c2=47.2;c3=17.27;c4=-12.659999999999998;output;
gene='gene02';c1=-21.74;c2=52.33;c3=-17.599999999999998;c4=19.470000000000002;output;
gene='gene03';c1=-4.61;c2=18.46;c3=21.53;c4=-26.4;output;
gene='gene04';c1=15.52;c2=27.59;c3=40.660000000000004;c4=47.730000000000004;output;
gene='gene05';c1=8.65;c2=12.72;c3=60.79;c4=57.86;output;
gene='gene06';c1=54.78;c2=19.85;c3=21.92;c4=68.99;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6137i,Rgx=^(gene|c2|c4)[[:space:]]*$,outdsd=v6137o,insensitive=1);
data v6137m(keep=metric value);set v6137o;length metric $120;array measured[*] c2 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6137o out=v6137s(keep=name type) noprint;run;data v6137s(keep=metric value);set v6137s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6137m data=v6137s;run;

data v6137m;set v6137m;format value best32.;run;
proc export data=v6137m outfile="%sysfunc(pathname(work))/V6137.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6137;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6137:;quit;
