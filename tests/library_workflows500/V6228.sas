/* New workflow V6228; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6228i;
length gene $80 grp $80 trait $80;
gene='id05';grp='g2';trait='t2';amount=169.04;output;
gene='id07';grp='g1';trait='t1';amount=3.06;output;
gene='id08';grp='g2';trait='t1';amount=990.07;output;
gene='id04';grp='g1';trait='t2';amount=961.03;output;
gene='id06';grp='g3';trait='t2';amount=310.05;output;
gene='id01';grp='g1';trait='t1';amount=88.0;output;
gene='id03';grp='g3';trait='t1';amount=302.02;output;
gene='id02';grp='g2';trait='t1';amount=137.01;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6228i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6228o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6228m(keep=metric value);set v6228o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6228m;set v6228m;format value best32.;run;
proc export data=v6228m outfile="%sysfunc(pathname(work))/V6228.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6228;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6228:;quit;
