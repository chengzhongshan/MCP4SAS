/* New workflow V6111; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6111i;
length gene $80 label1 $80 label2 $80;
gene='gene01';c1=40.13;c2=60.2;c3=31.27;label1='text0';label2='text1';output;
gene='gene02';c1=50.26;c2=41.33;c3=63.4;label1='text0';label2='text1';output;
gene='gene03';c1=16.39;c2=20.46;c3=12.530000000000001;label1='text0';label2='text1';output;
gene='gene04';c1=-14.48;c2=65.58999999999999;c3=-28.34;label1='text0';label2='text1';output;
gene='gene05';c1=-25.35;c2=-28.28;c3=37.79;label1='text0';label2='text1';output;
gene='gene06';c1=56.78;c2=52.85;c3=4.92;label1='text0';label2='text1';output;
gene='gene07';c1=10.91;c2=49.98;c3=-5.95;label1='text0';label2='text1';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6111i,outdsd=v6111o,numeric=1);
data v6111m(keep=metric value);set v6111o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6111m;set v6111m;format value best32.;run;
proc export data=v6111m outfile="%sysfunc(pathname(work))/V6111.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6111;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6111:;quit;
