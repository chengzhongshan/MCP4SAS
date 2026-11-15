/* New workflow V6155; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6155i;
length gene $80;
gene='gene01';c1=-0.87;c2=47.2;output;
gene='gene02';c1=-5.74;c2=8.33;output;
gene='gene03';c1=33.39;c2=34.46;output;
gene='gene04';c1=19.52;c2=14.59;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6155i,Rgx=^(c2)[[:space:]]*$,outdsd=v6155o);
data v6155m(keep=metric value);set v6155o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6155o out=v6155s(keep=name type) noprint;run;data v6155s(keep=metric value);set v6155s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6155m data=v6155s;run;

data v6155m;set v6155m;format value best32.;run;
proc export data=v6155m outfile="%sysfunc(pathname(work))/V6155.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6155;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6155:;quit;
