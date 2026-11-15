/* New workflow V6208; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6208i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=172.05;output;
gene='id04';grp='g1';trait='t2';amount=98.03;output;
gene='id02';grp='g2';trait='t1';amount=500.01;output;
gene='id08';grp='g2';trait='t1';amount=975.07;output;
gene='id05';grp='g2';trait='t2';amount=331.04;output;
gene='id03';grp='g3';trait='t1';amount=906.02;output;
gene='id01';grp='g1';trait='t1';amount=38.0;output;
gene='id07';grp='g1';trait='t1';amount=813.06;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6208i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6208o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6208m(keep=metric value);set v6208o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6208m;set v6208m;format value best32.;run;
proc export data=v6208m outfile="%sysfunc(pathname(work))/V6208.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6208;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6208:;quit;
