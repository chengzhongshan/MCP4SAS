/* New workflow V6154; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6154i;
length gene $80;
gene='gene01';c1=58.13;c2=-26.8;c3=25.27;c4=4.34;c5=-22.59;c6=12.48;output;
gene='gene02';c1=42.26;c2=45.33;c3=44.4;c4=-8.53;c5=21.540000000000003;c6=36.61;output;
gene='gene03';c1=-16.61;c2=10.46;c3=28.53;c4=26.6;c5=-14.33;c6=46.74;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6154i,Rgx=^(c1|c3|c5)[[:space:]]*$,outdsd=v6154o);
data v6154m(keep=metric value);set v6154o;length metric $120;array measured[*] c2 c4 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6154o out=v6154s(keep=name type) noprint;run;data v6154s(keep=metric value);set v6154s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6154m data=v6154s;run;

data v6154m;set v6154m;format value best32.;run;
proc export data=v6154m outfile="%sysfunc(pathname(work))/V6154.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6154;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6154:;quit;
