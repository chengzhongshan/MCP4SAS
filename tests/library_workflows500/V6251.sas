/* New workflow V6251; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6251i;
length gene $80 grp $80 trait $80;
gene='id02';grp='g2';trait='t1';amount=974.01;output;
gene='id04';grp='g1';trait='t2';amount=175.03;output;
gene='id06';grp='g3';trait='t2';amount=440.05;output;
gene='id01';grp='g1';trait='t1';amount=299.0;output;
gene='id03';grp='g3';trait='t1';amount=789.02;output;
gene='id07';grp='g1';trait='t1';amount=533.06;output;
gene='id05';grp='g2';trait='t2';amount=714.04;output;
gene='id10';grp='g1';trait='t2';amount=72.09;output;
gene='id08';grp='g2';trait='t1';amount=666.07;output;
gene='id09';grp='g3';trait='t1';amount=333.08;output;
gene='id11';grp='g2';trait='t2';amount=343.1;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6251i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6251o,num_grp_output_name=code);
data v6251m(keep=metric value);set v6251o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6251m;set v6251m;format value best32.;run;
proc export data=v6251m outfile="%sysfunc(pathname(work))/V6251.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6251;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6251:;quit;
