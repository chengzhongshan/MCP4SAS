/* New workflow V6236; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6236i;
length gene $80 grp $80 trait $80;
gene='id02';grp='g2';trait='t1';amount=950.01;output;
gene='id09';grp='g3';trait='t1';amount=727.08;output;
gene='id07';grp='g1';trait='t1';amount=966.06;output;
gene='id04';grp='g1';trait='t2';amount=853.03;output;
gene='id01';grp='g1';trait='t1';amount=395.0;output;
gene='id03';grp='g3';trait='t1';amount=11.02;output;
gene='id06';grp='g3';trait='t2';amount=482.05;output;
gene='id08';grp='g2';trait='t1';amount=764.07;output;
gene='id05';grp='g2';trait='t2';amount=902.04;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6236i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6236o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6236m(keep=metric value);set v6236o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6236m;set v6236m;format value best32.;run;
proc export data=v6236m outfile="%sysfunc(pathname(work))/V6236.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6236;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6236:;quit;
