/* New workflow V6142; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6142i;
length gene $80;
gene='gene01';c1=-2.87;c2=-6.8;c3=4.27;c4=41.34;output;
gene='gene02';c1=45.26;c2=-10.67;c3=-8.6;c4=52.47;output;
gene='gene03';c1=42.39;c2=-29.54;c3=49.53;c4=27.6;output;
gene='gene04';c1=51.52;c2=41.59;c3=-13.34;c4=65.72999999999999;output;
gene='gene05';c1=61.65;c2=24.72;c3=33.79;c4=50.86;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6142i,Rgx=^(c1|c3)[[:space:]]*$,outdsd=v6142o);
data v6142m(keep=metric value);set v6142o;length metric $120;array measured[*] c2 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6142o out=v6142s(keep=name type) noprint;run;data v6142s(keep=metric value);set v6142s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6142m data=v6142s;run;

data v6142m;set v6142m;format value best32.;run;
proc export data=v6142m outfile="%sysfunc(pathname(work))/V6142.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6142;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6142:;quit;
