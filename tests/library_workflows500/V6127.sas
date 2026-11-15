/* New workflow V6127; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6127i;
length gene $80;
gene='gene01';c1=52.13;c2=-22.8;c3=60.27;c4=33.34;output;
gene='gene02';c1=-3.74;c2=70.33;c3=37.4;c4=-28.529999999999998;output;
gene='gene03';c1=9.39;c2=38.46;c3=62.53;c4=-4.4;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6127i,Rgx=^(gene|c2|c4)[[:space:]]*$,outdsd=v6127o,insensitive=1);
data v6127m(keep=metric value);set v6127o;length metric $120;array measured[*] c2 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6127o out=v6127s(keep=name type) noprint;run;data v6127s(keep=metric value);set v6127s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6127m data=v6127s;run;

data v6127m;set v6127m;format value best32.;run;
proc export data=v6127m outfile="%sysfunc(pathname(work))/V6127.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6127;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6127:;quit;
