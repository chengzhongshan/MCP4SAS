/* New workflow V6238; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6238i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=633.05;output;
gene='id05';grp='g2';trait='t2';amount=446.04;output;
gene='id02';grp='g2';trait='t1';amount=729.01;output;
gene='id11';grp='g2';trait='t2';amount=507.1;output;
gene='id03';grp='g3';trait='t1';amount=305.02;output;
gene='id10';grp='g1';trait='t2';amount=691.09;output;
gene='id07';grp='g1';trait='t1';amount=163.06;output;
gene='id08';grp='g2';trait='t1';amount=459.07;output;
gene='id01';grp='g1';trait='t1';amount=537.0;output;
gene='id04';grp='g1';trait='t2';amount=983.03;output;
gene='id09';grp='g3';trait='t1';amount=320.08;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6238i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6238o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6238m(keep=metric value);set v6238o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6238m;set v6238m;format value best32.;run;
proc export data=v6238m outfile="%sysfunc(pathname(work))/V6238.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6238;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6238:;quit;
