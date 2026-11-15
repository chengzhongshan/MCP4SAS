/* New workflow V6233; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6233i;
length gene $80 grp $80 trait $80;
gene='id01';grp='g1';trait='t1';amount=483.0;output;
gene='id05';grp='g2';trait='t2';amount=634.04;output;
gene='id07';grp='g1';trait='t1';amount=497.06;output;
gene='id06';grp='g3';trait='t2';amount=65.05;output;
gene='id08';grp='g2';trait='t1';amount=445.07;output;
gene='id09';grp='g3';trait='t1';amount=742.08;output;
gene='id04';grp='g1';trait='t2';amount=865.03;output;
gene='id13';grp='g1';trait='t1';amount=833.12;output;
gene='id03';grp='g3';trait='t1';amount=880.02;output;
gene='id12';grp='g3';trait='t2';amount=625.11;output;
gene='id02';grp='g2';trait='t1';amount=323.01;output;
gene='id11';grp='g2';trait='t2';amount=121.1;output;
gene='id10';grp='g1';trait='t2';amount=988.09;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6233i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6233o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6233m(keep=metric value);set v6233o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6233m;set v6233m;format value best32.;run;
proc export data=v6233m outfile="%sysfunc(pathname(work))/V6233.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6233;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6233:;quit;
