/* New workflow V6156; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6156i;
length gene $80;
gene='gene01';c1=48.13;c2=-18.8;c3=29.27;output;
gene='gene02';c1=16.26;c2=-9.67;c3=-26.599999999999998;output;
gene='gene03';c1=-7.61;c2=60.46;c3=65.53;output;
gene='gene04';c1=68.52;c2=-15.41;c3=54.660000000000004;output;
gene='gene05';c1=-27.35;c2=30.72;c3=42.79;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6156i,Rgx=^(c1|c3)[[:space:]]*$,outdsd=v6156o);
data v6156m(keep=metric value);set v6156o;length metric $120;array measured[*] c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6156o out=v6156s(keep=name type) noprint;run;data v6156s(keep=metric value);set v6156s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6156m data=v6156s;run;

data v6156m;set v6156m;format value best32.;run;
proc export data=v6156m outfile="%sysfunc(pathname(work))/V6156.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6156;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6156:;quit;
