/* New workflow V6121; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6121i;
length gene $80;
gene='gene01';c1=11.13;c2=-9.799999999999999;c3=-28.73;output;
gene='gene02';c1=-27.74;c2=43.33;c3=29.400000000000002;output;
gene='gene03';c1=33.39;c2=13.46;c3=-13.469999999999999;output;
gene='gene04';c1=-16.48;c2=-11.41;c3=7.659999999999999;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6121i,Rgx=^(gene|c2)[[:space:]]*$,outdsd=v6121o,insensitive=1);
data v6121m(keep=metric value);set v6121o;length metric $120;array measured[*] c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6121o out=v6121s(keep=name type) noprint;run;data v6121s(keep=metric value);set v6121s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6121m data=v6121s;run;

data v6121m;set v6121m;format value best32.;run;
proc export data=v6121m outfile="%sysfunc(pathname(work))/V6121.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6121;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6121:;quit;
