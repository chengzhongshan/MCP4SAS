/* New workflow V6123; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6123i;
length gene $80;
gene='gene01';c1=20.13;c2=55.2;c3=-8.729999999999999;c4=0.34;c5=-12.59;output;
gene='gene02';c1=33.26;c2=-6.67;c3=44.4;c4=67.47;c5=12.54;output;
gene='gene03';c1=51.39;c2=44.46;c3=-23.47;c4=56.6;c5=-16.33;output;
gene='gene04';c1=25.52;c2=19.59;c3=6.659999999999999;c4=70.72999999999999;c5=-13.200000000000001;output;
gene='gene05';c1=-13.35;c2=28.72;c3=25.79;c4=23.86;c5=42.93;output;
gene='gene06';c1=-6.22;c2=62.85;c3=8.92;c4=24.990000000000002;c5=39.06;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6123i,Rgx=^(gene|c2|c4)[[:space:]]*$,outdsd=v6123o,insensitive=1);
data v6123m(keep=metric value);set v6123o;length metric $120;array measured[*] c2 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6123o out=v6123s(keep=name type) noprint;run;data v6123s(keep=metric value);set v6123s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6123m data=v6123s;run;

data v6123m;set v6123m;format value best32.;run;
proc export data=v6123m outfile="%sysfunc(pathname(work))/V6123.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6123;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6123:;quit;
