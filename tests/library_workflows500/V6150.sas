/* New workflow V6150; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6150i;
length gene $80;
gene='gene01';c1=44.13;c2=30.2;output;
gene='gene02';c1=43.26;c2=33.33;output;
gene='gene03';c1=44.39;c2=11.46;output;
gene='gene04';c1=48.52;c2=39.59;output;
gene='gene05';c1=3.65;c2=8.72;output;
gene='gene06';c1=55.78;c2=66.85;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6150i,Rgx=^(c1)[[:space:]]*$,outdsd=v6150o);
data v6150m(keep=metric value);set v6150o;length metric $120;array measured[*] c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6150o out=v6150s(keep=name type) noprint;run;data v6150s(keep=metric value);set v6150s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6150m data=v6150s;run;

data v6150m;set v6150m;format value best32.;run;
proc export data=v6150m outfile="%sysfunc(pathname(work))/V6150.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6150;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6150:;quit;
