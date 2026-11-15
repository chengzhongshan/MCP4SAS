/* New workflow V6132; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6132i;
length gene $80;
gene='gene01';c1=51.13;c2=29.2;c3=49.27;c4=38.34;output;
gene='gene02';c1=11.26;c2=51.33;c3=9.4;c4=35.47;output;
gene='gene03';c1=35.39;c2=49.46;c3=65.53;c4=-10.399999999999999;output;
gene='gene04';c1=-16.48;c2=68.58999999999999;c3=9.66;c4=43.730000000000004;output;
gene='gene05';c1=-3.35;c2=16.72;c3=-15.209999999999999;c4=0.8600000000000001;output;
gene='gene06';c1=46.78;c2=-29.15;c3=66.92;c4=35.99;output;
gene='gene07';c1=55.91;c2=-29.02;c3=-0.9499999999999998;c4=-5.88;output;
gene='gene08';c1=18.04;c2=15.11;c3=-16.82;c4=-27.75;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6132i,Rgx=^(gene|c1|c3)[[:space:]]*$,outdsd=v6132o,insensitive=1);
data v6132m(keep=metric value);set v6132o;length metric $120;array measured[*] c1 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6132o out=v6132s(keep=name type) noprint;run;data v6132s(keep=metric value);set v6132s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6132m data=v6132s;run;

data v6132m;set v6132m;format value best32.;run;
proc export data=v6132m outfile="%sysfunc(pathname(work))/V6132.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6132;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6132:;quit;
