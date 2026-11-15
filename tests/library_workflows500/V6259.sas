/* New workflow V6259; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6259i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=702.02;output;
gene='id01';grp='g1';trait='t1';amount=15.0;output;
gene='id04';grp='g1';trait='t2';amount=719.03;output;
gene='id07';grp='g1';trait='t1';amount=7.06;output;
gene='id02';grp='g2';trait='t1';amount=672.01;output;
gene='id06';grp='g3';trait='t2';amount=884.05;output;
gene='id05';grp='g2';trait='t2';amount=507.04;output;
gene='id08';grp='g2';trait='t1';amount=562.07;output;
gene='id12';grp='g3';trait='t2';amount=818.11;output;
gene='id11';grp='g2';trait='t2';amount=930.1;output;
gene='id10';grp='g1';trait='t2';amount=581.09;output;
gene='id09';grp='g3';trait='t1';amount=564.08;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6259i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6259o,num_grp_output_name=code);
data v6259m(keep=metric value);set v6259o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6259m;set v6259m;format value best32.;run;
proc export data=v6259m outfile="%sysfunc(pathname(work))/V6259.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6259;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6259:;quit;
