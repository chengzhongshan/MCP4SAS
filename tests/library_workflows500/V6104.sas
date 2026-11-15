/* New workflow V6104; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6104i;
length gene $80 label1 $80 label2 $80 label3 $80 label4 $80 label5 $80;
gene='gene01';c1=-29.87;c2=27.2;c3=36.27;c4=34.34;c5=45.410000000000004;c6=-10.52;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene02';c1=31.26;c2=55.33;c3=29.400000000000002;c4=64.47;c5=-13.46;c6=5.609999999999999;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene03';c1=33.39;c2=-19.54;c3=-19.47;c4=5.6;c5=-23.33;c6=23.740000000000002;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene04';c1=-8.48;c2=-19.41;c3=-1.3399999999999999;c4=35.730000000000004;c5=30.8;c6=68.86999999999999;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene05';c1=-18.35;c2=-18.28;c3=26.79;c4=32.86;c5=7.930000000000001;c6=5.0;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene06';c1=4.78;c2=36.85;c3=-10.08;c4=37.99;c5=7.0600000000000005;c6=21.130000000000003;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene07';c1=-10.09;c2=44.98;c3=20.05;c4=14.120000000000001;c5=-24.81;c6=43.26;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6104i,outdsd=v6104o,numeric=0);
data v6104m(keep=metric value);set v6104o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6104m;set v6104m;format value best32.;run;
proc export data=v6104m outfile="%sysfunc(pathname(work))/V6104.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6104;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6104:;quit;
