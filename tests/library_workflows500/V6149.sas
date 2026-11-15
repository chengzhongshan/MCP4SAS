/* New workflow V6149; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6149i;
length gene $80;
gene='gene01';c1=-22.87;c2=48.2;c3=-9.729999999999999;c4=-11.659999999999998;c5=-4.59;c6=-2.52;output;
gene='gene02';c1=30.26;c2=55.33;c3=-26.599999999999998;c4=50.47;c5=-0.45999999999999996;c6=29.610000000000003;output;
gene='gene03';c1=42.39;c2=52.46;c3=38.53;c4=6.6;c5=-27.33;c6=-9.26;output;
gene='gene04';c1=46.52;c2=64.58999999999999;c3=58.660000000000004;c4=-16.27;c5=53.800000000000004;c6=52.870000000000005;output;
gene='gene05';c1=65.65;c2=-17.28;c3=7.79;c4=-15.139999999999999;c5=27.93;c6=68.0;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6149i,Rgx=^(c2|c4|c6)[[:space:]]*$,outdsd=v6149o);
data v6149m(keep=metric value);set v6149o;length metric $120;array measured[*] c1 c3 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6149o out=v6149s(keep=name type) noprint;run;data v6149s(keep=metric value);set v6149s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6149m data=v6149s;run;

data v6149m;set v6149m;format value best32.;run;
proc export data=v6149m outfile="%sysfunc(pathname(work))/V6149.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6149;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6149:;quit;
