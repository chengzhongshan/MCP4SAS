/* New workflow V6138; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6138i;
length gene $80;
gene='gene01';c1=68.13;c2=-20.8;c3=32.27;c4=-14.659999999999998;c5=2.41;output;
gene='gene02';c1=3.26;c2=45.33;c3=27.400000000000002;c4=-14.53;c5=-3.46;output;
gene='gene03';c1=32.39;c2=63.46;c3=7.529999999999999;c4=-3.4;c5=27.67;output;
gene='gene04';c1=24.52;c2=21.59;c3=-28.34;c4=-27.27;c5=59.800000000000004;output;
gene='gene05';c1=32.65;c2=36.72;c3=-29.21;c4=5.86;c5=32.93;output;
gene='gene06';c1=53.78;c2=48.85;c3=45.92;c4=16.990000000000002;c5=46.06;output;
gene='gene07';c1=-15.09;c2=45.98;c3=-25.95;c4=14.120000000000001;c5=65.19;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6138i,Rgx=^(gene|c1|c3|c5)[[:space:]]*$,outdsd=v6138o,insensitive=1);
data v6138m(keep=metric value);set v6138o;length metric $120;array measured[*] c1 c3 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6138o out=v6138s(keep=name type) noprint;run;data v6138s(keep=metric value);set v6138s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6138m data=v6138s;run;

data v6138m;set v6138m;format value best32.;run;
proc export data=v6138m outfile="%sysfunc(pathname(work))/V6138.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6138;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6138:;quit;
