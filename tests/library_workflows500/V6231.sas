/* New workflow V6231; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6231i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=8.02;output;
gene='id07';grp='g1';trait='t1';amount=281.06;output;
gene='id10';grp='g1';trait='t2';amount=731.09;output;
gene='id01';grp='g1';trait='t1';amount=272.0;output;
gene='id02';grp='g2';trait='t1';amount=525.01;output;
gene='id09';grp='g3';trait='t1';amount=971.08;output;
gene='id06';grp='g3';trait='t2';amount=164.05;output;
gene='id04';grp='g1';trait='t2';amount=271.03;output;
gene='id08';grp='g2';trait='t1';amount=805.07;output;
gene='id11';grp='g2';trait='t2';amount=745.1;output;
gene='id05';grp='g2';trait='t2';amount=880.04;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6231i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6231o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6231m(keep=metric value);set v6231o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6231m;set v6231m;format value best32.;run;
proc export data=v6231m outfile="%sysfunc(pathname(work))/V6231.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6231;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6231:;quit;
