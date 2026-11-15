/* New workflow V6214; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6214i;
length gene $80 grp $80 trait $80;
gene='id04';grp='g1';trait='t2';amount=340.03;output;
gene='id06';grp='g3';trait='t2';amount=550.05;output;
gene='id02';grp='g2';trait='t1';amount=788.01;output;
gene='id05';grp='g2';trait='t2';amount=929.04;output;
gene='id03';grp='g3';trait='t1';amount=687.02;output;
gene='id07';grp='g1';trait='t1';amount=677.06;output;
gene='id01';grp='g1';trait='t1';amount=309.0;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6214i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6214o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6214m(keep=metric value);set v6214o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6214m;set v6214m;format value best32.;run;
proc export data=v6214m outfile="%sysfunc(pathname(work))/V6214.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6214;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6214:;quit;
