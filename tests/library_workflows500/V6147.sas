/* New workflow V6147; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6147i;
length gene $80;
gene='gene01';c1=49.13;c2=13.200000000000001;c3=46.27;c4=-20.66;output;
gene='gene02';c1=37.26;c2=35.33;c3=-13.6;c4=28.470000000000002;output;
gene='gene03';c1=-3.61;c2=-20.54;c3=7.529999999999999;c4=8.600000000000001;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6147i,Rgx=^(c2|c4)[[:space:]]*$,outdsd=v6147o);
data v6147m(keep=metric value);set v6147o;length metric $120;array measured[*] c1 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6147o out=v6147s(keep=name type) noprint;run;data v6147s(keep=metric value);set v6147s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6147m data=v6147s;run;

data v6147m;set v6147m;format value best32.;run;
proc export data=v6147m outfile="%sysfunc(pathname(work))/V6147.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6147;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6147:;quit;
