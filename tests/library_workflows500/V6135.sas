/* New workflow V6135; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6135i;
length gene $80;
gene='gene01';c1=38.13;c2=40.2;output;
gene='gene02';c1=-15.74;c2=56.33;output;
gene='gene03';c1=-16.61;c2=17.46;output;
gene='gene04';c1=51.52;c2=25.59;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6135i,Rgx=^(gene|c2)[[:space:]]*$,outdsd=v6135o,insensitive=1);
data v6135m(keep=metric value);set v6135o;length metric $120;array measured[*] c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6135o out=v6135s(keep=name type) noprint;run;data v6135s(keep=metric value);set v6135s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6135m data=v6135s;run;

data v6135m;set v6135m;format value best32.;run;
proc export data=v6135m outfile="%sysfunc(pathname(work))/V6135.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6135;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6135:;quit;
