/* New workflow V6216; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6216i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=414.02;output;
gene='id04';grp='g1';trait='t2';amount=821.03;output;
gene='id01';grp='g1';trait='t1';amount=627.0;output;
gene='id07';grp='g1';trait='t1';amount=676.06;output;
gene='id02';grp='g2';trait='t1';amount=762.01;output;
gene='id05';grp='g2';trait='t2';amount=265.04;output;
gene='id06';grp='g3';trait='t2';amount=524.05;output;
gene='id08';grp='g2';trait='t1';amount=91.07;output;
gene='id09';grp='g3';trait='t1';amount=485.08;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6216i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6216o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6216m(keep=metric value);set v6216o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6216m;set v6216m;format value best32.;run;
proc export data=v6216m outfile="%sysfunc(pathname(work))/V6216.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6216;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6216:;quit;
