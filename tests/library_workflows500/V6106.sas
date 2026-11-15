/* New workflow V6106; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6106i;
length gene $80 label1 $80 label2 $80;
gene='gene01';c1=7.13;c2=36.2;c3=14.270000000000001;label1='text0';label2='text1';output;
gene='gene02';c1=29.26;c2=60.33;c3=-24.599999999999998;label1='text0';label2='text1';output;
gene='gene03';c1=25.39;c2=6.46;c3=2.5300000000000002;label1='text0';label2='text1';output;
gene='gene04';c1=11.52;c2=2.59;c3=-23.34;label1='text0';label2='text1';output;
gene='gene05';c1=69.65;c2=63.72;c3=19.79;label1='text0';label2='text1';output;
gene='gene06';c1=24.78;c2=22.85;c3=10.92;label1='text0';label2='text1';output;
gene='gene07';c1=69.91;c2=35.98;c3=8.05;label1='text0';label2='text1';output;
gene='gene08';c1=-19.96;c2=46.11;c3=29.18;label1='text0';label2='text1';output;
gene='gene09';c1=-2.83;c2=38.24;c3=12.31;label1='text0';label2='text1';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6106i,outdsd=v6106o,numeric=0);
data v6106m(keep=metric value);set v6106o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6106m;set v6106m;format value best32.;run;
proc export data=v6106m outfile="%sysfunc(pathname(work))/V6106.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6106;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6106:;quit;
