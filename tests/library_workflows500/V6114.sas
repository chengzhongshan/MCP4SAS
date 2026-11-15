/* New workflow V6114; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6114i;
length gene $80 label1 $80 label2 $80 label3 $80 label4 $80 label5 $80;
gene='gene01';c1=4.13;c2=-7.8;c3=-24.73;c4=-3.66;c5=34.410000000000004;c6=-12.52;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene02';c1=23.26;c2=46.33;c3=35.4;c4=66.47;c5=51.54;c6=41.61;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene03';c1=33.39;c2=17.46;c3=11.530000000000001;c4=66.6;c5=-22.33;c6=53.74;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6114i,outdsd=v6114o,numeric=0);
data v6114m(keep=metric value);set v6114o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6114m;set v6114m;format value best32.;run;
proc export data=v6114m outfile="%sysfunc(pathname(work))/V6114.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6114;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6114:;quit;
