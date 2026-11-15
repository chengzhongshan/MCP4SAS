/* New workflow V6118; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6118i;
length gene $80 label1 $80 label2 $80 label3 $80 label4 $80;
gene='gene01';c1=23.13;c2=-26.8;c3=-17.73;c4=31.34;c5=29.41;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene02';c1=18.26;c2=38.33;c3=-13.6;c4=-11.53;c5=52.54;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene03';c1=70.39;c2=34.46;c3=-13.469999999999999;c4=-1.4;c5=12.67;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene04';c1=9.52;c2=66.58999999999999;c3=23.66;c4=63.730000000000004;c5=17.8;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene05';c1=61.65;c2=-23.28;c3=52.79;c4=35.86;c5=26.93;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene06';c1=42.78;c2=1.85;c3=-9.08;c4=43.99;c5=29.060000000000002;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene07';c1=-8.09;c2=45.98;c3=70.05;c4=15.120000000000001;c5=31.19;label1='text0';label2='text1';label3='text2';label4='text3';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6118i,outdsd=v6118o,numeric=0);
data v6118m(keep=metric value);set v6118o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6118m;set v6118m;format value best32.;run;
proc export data=v6118m outfile="%sysfunc(pathname(work))/V6118.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6118;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6118:;quit;
