/* New workflow V6206; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6206i;
length gene $80 grp $80 trait $80;
gene='id04';grp='g1';trait='t2';amount=653.03;output;
gene='id03';grp='g3';trait='t1';amount=85.02;output;
gene='id13';grp='g1';trait='t1';amount=853.12;output;
gene='id11';grp='g2';trait='t2';amount=553.1;output;
gene='id10';grp='g1';trait='t2';amount=697.09;output;
gene='id02';grp='g2';trait='t1';amount=724.01;output;
gene='id09';grp='g3';trait='t1';amount=259.08;output;
gene='id01';grp='g1';trait='t1';amount=473.0;output;
gene='id12';grp='g3';trait='t2';amount=811.11;output;
gene='id06';grp='g3';trait='t2';amount=103.05;output;
gene='id08';grp='g2';trait='t1';amount=591.07;output;
gene='id05';grp='g2';trait='t2';amount=134.04;output;
gene='id07';grp='g1';trait='t1';amount=737.06;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6206i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6206o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6206m(keep=metric value);set v6206o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6206m;set v6206m;format value best32.;run;
proc export data=v6206m outfile="%sysfunc(pathname(work))/V6206.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6206;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6206:;quit;
