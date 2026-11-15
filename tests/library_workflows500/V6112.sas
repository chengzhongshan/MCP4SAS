/* New workflow V6112; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6112i;
length gene $80 label1 $80 label2 $80 label3 $80;
gene='gene01';c1=67.13;c2=23.2;c3=-8.729999999999999;c4=-4.66;label1='text0';label2='text1';label3='text2';output;
gene='gene02';c1=15.26;c2=58.33;c3=12.4;c4=13.47;label1='text0';label2='text1';label3='text2';output;
gene='gene03';c1=39.39;c2=38.46;c3=40.53;c4=22.6;label1='text0';label2='text1';label3='text2';output;
gene='gene04';c1=-15.48;c2=53.59;c3=-8.34;c4=47.730000000000004;label1='text0';label2='text1';label3='text2';output;
gene='gene05';c1=-6.35;c2=57.72;c3=-17.21;c4=11.860000000000001;label1='text0';label2='text1';label3='text2';output;
gene='gene06';c1=37.78;c2=23.85;c3=39.92;c4=60.99;label1='text0';label2='text1';label3='text2';output;
gene='gene07';c1=31.91;c2=-17.02;c3=11.05;c4=38.12;label1='text0';label2='text1';label3='text2';output;
gene='gene08';c1=-3.96;c2=-6.89;c3=56.18;c4=-8.75;label1='text0';label2='text1';label3='text2';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6112i,outdsd=v6112o,numeric=0);
data v6112m(keep=metric value);set v6112o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6112m;set v6112m;format value best32.;run;
proc export data=v6112m outfile="%sysfunc(pathname(work))/V6112.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6112;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6112:;quit;
