/* New workflow V6255; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6255i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=287.05;output;
gene='id02';grp='g2';trait='t1';amount=102.01;output;
gene='id04';grp='g1';trait='t2';amount=291.03;output;
gene='id07';grp='g1';trait='t1';amount=604.06;output;
gene='id03';grp='g3';trait='t1';amount=51.02;output;
gene='id05';grp='g2';trait='t2';amount=766.04;output;
gene='id08';grp='g2';trait='t1';amount=722.07;output;
gene='id01';grp='g1';trait='t1';amount=769.0;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6255i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6255o,num_grp_output_name=code);
data v6255m(keep=metric value);set v6255o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6255m;set v6255m;format value best32.;run;
proc export data=v6255m outfile="%sysfunc(pathname(work))/V6255.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6255;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6255:;quit;
