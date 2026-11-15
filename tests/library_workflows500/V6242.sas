/* New workflow V6242; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6242i;
length gene $80 grp $80 trait $80;
gene='id09';grp='g3';trait='t1';amount=209.08;output;
gene='id05';grp='g2';trait='t2';amount=613.04;output;
gene='id06';grp='g3';trait='t2';amount=537.05;output;
gene='id07';grp='g1';trait='t1';amount=313.06;output;
gene='id02';grp='g2';trait='t1';amount=168.01;output;
gene='id03';grp='g3';trait='t1';amount=779.02;output;
gene='id01';grp='g1';trait='t1';amount=59.0;output;
gene='id08';grp='g2';trait='t1';amount=419.07;output;
gene='id04';grp='g1';trait='t2';amount=322.03;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6242i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6242o,num_grp_output_name=code);
data v6242m(keep=metric value);set v6242o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6242m;set v6242m;format value best32.;run;
proc export data=v6242m outfile="%sysfunc(pathname(work))/V6242.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6242;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6242:;quit;
