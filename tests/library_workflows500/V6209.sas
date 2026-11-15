/* New workflow V6209; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6209i;
length gene $80 grp $80 trait $80;
gene='id09';grp='g3';trait='t1';amount=593.08;output;
gene='id07';grp='g1';trait='t1';amount=394.06;output;
gene='id05';grp='g2';trait='t2';amount=572.04;output;
gene='id04';grp='g1';trait='t2';amount=320.03;output;
gene='id08';grp='g2';trait='t1';amount=743.07;output;
gene='id02';grp='g2';trait='t1';amount=827.01;output;
gene='id06';grp='g3';trait='t2';amount=662.05;output;
gene='id03';grp='g3';trait='t1';amount=946.02;output;
gene='id01';grp='g1';trait='t1';amount=835.0;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6209i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6209o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6209m(keep=metric value);set v6209o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6209m;set v6209m;format value best32.;run;
proc export data=v6209m outfile="%sysfunc(pathname(work))/V6209.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6209;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6209:;quit;
