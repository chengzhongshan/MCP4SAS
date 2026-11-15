/* New workflow V6146; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6146i;
length gene $80;
gene='gene01';c1=12.13;c2=60.2;c3=16.27;output;
gene='gene02';c1=7.26;c2=18.330000000000002;c3=-13.6;output;
gene='gene03';c1=0.39;c2=57.46;c3=16.53;output;
gene='gene04';c1=5.52;c2=4.59;c3=-27.34;output;
gene='gene05';c1=5.65;c2=37.72;c3=57.79;output;
gene='gene06';c1=51.78;c2=-13.15;c3=26.92;output;
gene='gene07';c1=43.91;c2=1.9800000000000002;c3=-19.95;output;
gene='gene08';c1=70.04;c2=66.11;c3=65.18;output;
gene='gene09';c1=33.17;c2=38.24;c3=22.310000000000002;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6146i,Rgx=^(c1|c3)[[:space:]]*$,outdsd=v6146o);
data v6146m(keep=metric value);set v6146o;length metric $120;array measured[*] c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6146o out=v6146s(keep=name type) noprint;run;data v6146s(keep=metric value);set v6146s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6146m data=v6146s;run;

data v6146m;set v6146m;format value best32.;run;
proc export data=v6146m outfile="%sysfunc(pathname(work))/V6146.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6146;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6146:;quit;
