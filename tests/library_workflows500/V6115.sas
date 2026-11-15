/* New workflow V6115; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6115i;
length gene $80 label1 $80;
gene='gene01';c1=15.13;c2=42.2;label1='text0';output;
gene='gene02';c1=-3.74;c2=56.33;label1='text0';output;
gene='gene03';c1=-21.61;c2=19.46;label1='text0';output;
gene='gene04';c1=36.52;c2=24.59;label1='text0';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6115i,outdsd=v6115o,numeric=1);
data v6115m(keep=metric value);set v6115o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6115m;set v6115m;format value best32.;run;
proc export data=v6115m outfile="%sysfunc(pathname(work))/V6115.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6115;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6115:;quit;
