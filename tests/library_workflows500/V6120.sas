/* New workflow V6120; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6120i;
length gene $80 label1 $80;
gene='gene01';c1=41.13;c2=37.2;label1='text0';output;
gene='gene02';c1=-23.74;c2=70.33;label1='text0';output;
gene='gene03';c1=21.39;c2=54.46;label1='text0';output;
gene='gene04';c1=-1.48;c2=36.59;label1='text0';output;
gene='gene05';c1=46.65;c2=13.72;label1='text0';output;
gene='gene06';c1=66.78;c2=-21.15;label1='text0';output;
gene='gene07';c1=-20.09;c2=-0.019999999999999962;label1='text0';output;
gene='gene08';c1=70.04;c2=65.11;label1='text0';output;
gene='gene09';c1=56.17;c2=51.24;label1='text0';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6120i,outdsd=v6120o,numeric=0);
data v6120m(keep=metric value);set v6120o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6120m;set v6120m;format value best32.;run;
proc export data=v6120m outfile="%sysfunc(pathname(work))/V6120.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6120;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6120:;quit;
