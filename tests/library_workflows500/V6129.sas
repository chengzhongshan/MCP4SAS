/* New workflow V6129; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6129i;
length gene $80;
gene='gene01';c1=-4.87;c2=-13.799999999999999;c3=58.27;c4=40.34;c5=47.410000000000004;c6=-28.52;output;
gene='gene02';c1=64.26;c2=62.33;c3=-27.599999999999998;c4=55.47;c5=65.54;c6=2.61;output;
gene='gene03';c1=63.39;c2=-14.54;c3=39.53;c4=42.6;c5=40.67;c6=-21.259999999999998;output;
gene='gene04';c1=-12.48;c2=47.59;c3=-13.34;c4=32.730000000000004;c5=-18.2;c6=2.87;output;
gene='gene05';c1=18.65;c2=0.72;c3=-4.21;c4=-24.14;c5=-2.0700000000000003;c6=11.0;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6129i,Rgx=^(gene|c2|c4|c6)[[:space:]]*$,outdsd=v6129o,insensitive=1);
data v6129m(keep=metric value);set v6129o;length metric $120;array measured[*] c2 c4 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6129o out=v6129s(keep=name type) noprint;run;data v6129s(keep=metric value);set v6129s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6129m data=v6129s;run;

data v6129m;set v6129m;format value best32.;run;
proc export data=v6129m outfile="%sysfunc(pathname(work))/V6129.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6129;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6129:;quit;
