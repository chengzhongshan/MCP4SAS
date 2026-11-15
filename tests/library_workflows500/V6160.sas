/* New workflow V6160; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6160i;
length gene $80;
gene='gene01';c1=42.13;c2=68.19999999999999;output;
gene='gene02';c1=27.26;c2=51.33;output;
gene='gene03';c1=-6.61;c2=-0.54;output;
gene='gene04';c1=-13.48;c2=23.59;output;
gene='gene05';c1=48.65;c2=-13.28;output;
gene='gene06';c1=45.78;c2=-16.15;output;
gene='gene07';c1=-12.09;c2=24.98;output;
gene='gene08';c1=-4.96;c2=19.11;output;
gene='gene09';c1=48.17;c2=37.24;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6160i,Rgx=^(c1)[[:space:]]*$,outdsd=v6160o);
data v6160m(keep=metric value);set v6160o;length metric $120;array measured[*] c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6160o out=v6160s(keep=name type) noprint;run;data v6160s(keep=metric value);set v6160s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6160m data=v6160s;run;

data v6160m;set v6160m;format value best32.;run;
proc export data=v6160m outfile="%sysfunc(pathname(work))/V6160.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6160;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6160:;quit;
