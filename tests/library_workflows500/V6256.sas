/* New workflow V6256; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6256i;
length gene $80 grp $80 trait $80;
gene='id01';grp='g1';trait='t1';amount=265.0;output;
gene='id03';grp='g3';trait='t1';amount=239.02;output;
gene='id06';grp='g3';trait='t2';amount=341.05;output;
gene='id05';grp='g2';trait='t2';amount=954.04;output;
gene='id08';grp='g2';trait='t1';amount=691.07;output;
gene='id02';grp='g2';trait='t1';amount=750.01;output;
gene='id07';grp='g1';trait='t1';amount=552.06;output;
gene='id04';grp='g1';trait='t2';amount=314.03;output;
gene='id09';grp='g3';trait='t1';amount=320.08;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6256i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6256o,num_grp_output_name=code);
data v6256m(keep=metric value);set v6256o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6256m;set v6256m;format value best32.;run;
proc export data=v6256m outfile="%sysfunc(pathname(work))/V6256.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6256;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6256:;quit;
