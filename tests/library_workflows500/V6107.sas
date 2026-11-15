/* New workflow V6107; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6107i;
length gene $80 label1 $80 label2 $80 label3 $80;
gene='gene01';c1=0.13;c2=27.2;c3=40.27;c4=39.34;label1='text0';label2='text1';label3='text2';output;
gene='gene02';c1=70.26;c2=-13.67;c3=68.4;c4=14.47;label1='text0';label2='text1';label3='text2';output;
gene='gene03';c1=39.39;c2=7.46;c3=-9.469999999999999;c4=53.6;label1='text0';label2='text1';label3='text2';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6107i,outdsd=v6107o,numeric=1);
data v6107m(keep=metric value);set v6107o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6107m;set v6107m;format value best32.;run;
proc export data=v6107m outfile="%sysfunc(pathname(work))/V6107.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6107;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6107:;quit;
