/* New workflow V6200; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6200i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=920.05;output;
gene='id11';grp='g2';trait='t2';amount=867.1;output;
gene='id05';grp='g2';trait='t2';amount=547.04;output;
gene='id13';grp='g1';trait='t1';amount=802.12;output;
gene='id04';grp='g1';trait='t2';amount=369.03;output;
gene='id02';grp='g2';trait='t1';amount=722.01;output;
gene='id12';grp='g3';trait='t2';amount=5.11;output;
gene='id09';grp='g3';trait='t1';amount=249.08;output;
gene='id10';grp='g1';trait='t2';amount=678.09;output;
gene='id03';grp='g3';trait='t1';amount=922.02;output;
gene='id07';grp='g1';trait='t1';amount=405.06;output;
gene='id08';grp='g2';trait='t1';amount=573.07;output;
gene='id01';grp='g1';trait='t1';amount=661.0;output;
run;
%n26_number_rows_by_grp(dsdin=v6200i,grp_var=grp,num_var4sort=amount,descending_or_not=0,dsdout=v6200o);
data v6200m(keep=metric value);set v6200o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6200m;set v6200m;format value best32.;run;
proc export data=v6200m outfile="%sysfunc(pathname(work))/V6200.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6200;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6200:;quit;
