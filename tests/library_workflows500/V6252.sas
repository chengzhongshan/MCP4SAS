/* New workflow V6252; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6252i;
length gene $80 grp $80 trait $80;
gene='id08';grp='g2';trait='t1';amount=975.07;output;
gene='id02';grp='g2';trait='t1';amount=930.01;output;
gene='id05';grp='g2';trait='t2';amount=148.04;output;
gene='id07';grp='g1';trait='t1';amount=241.06;output;
gene='id04';grp='g1';trait='t2';amount=953.03;output;
gene='id11';grp='g2';trait='t2';amount=491.1;output;
gene='id01';grp='g1';trait='t1';amount=84.0;output;
gene='id03';grp='g3';trait='t1';amount=650.02;output;
gene='id12';grp='g3';trait='t2';amount=242.11;output;
gene='id06';grp='g3';trait='t2';amount=971.05;output;
gene='id09';grp='g3';trait='t1';amount=510.08;output;
gene='id10';grp='g1';trait='t2';amount=412.09;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6252i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6252o,num_grp_output_name=code);
data v6252m(keep=metric value);set v6252o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6252m;set v6252m;format value best32.;run;
proc export data=v6252m outfile="%sysfunc(pathname(work))/V6252.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6252;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6252:;quit;
