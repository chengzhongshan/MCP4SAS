/* New workflow V6221; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6221i;
length gene $80 grp $80 trait $80;
gene='id05';grp='g2';trait='t2';amount=800.04;output;
gene='id08';grp='g2';trait='t1';amount=547.07;output;
gene='id06';grp='g3';trait='t2';amount=860.05;output;
gene='id01';grp='g1';trait='t1';amount=892.0;output;
gene='id02';grp='g2';trait='t1';amount=968.01;output;
gene='id04';grp='g1';trait='t2';amount=732.03;output;
gene='id07';grp='g1';trait='t1';amount=108.06;output;
gene='id03';grp='g3';trait='t1';amount=263.02;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6221i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6221o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6221m(keep=metric value);set v6221o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6221m;set v6221m;format value best32.;run;
proc export data=v6221m outfile="%sysfunc(pathname(work))/V6221.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6221;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6221:;quit;
