/* New workflow V6197; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6197i;
length gene $80 grp $80 trait $80;
gene='id10';grp='g1';trait='t2';amount=85.09;output;
gene='id06';grp='g3';trait='t2';amount=626.05;output;
gene='id04';grp='g1';trait='t2';amount=198.03;output;
gene='id08';grp='g2';trait='t1';amount=580.07;output;
gene='id09';grp='g3';trait='t1';amount=591.08;output;
gene='id05';grp='g2';trait='t2';amount=484.04;output;
gene='id02';grp='g2';trait='t1';amount=516.01;output;
gene='id01';grp='g1';trait='t1';amount=951.0;output;
gene='id07';grp='g1';trait='t1';amount=797.06;output;
gene='id03';grp='g3';trait='t1';amount=879.02;output;
run;
%n26_number_rows_by_grp(dsdin=v6197i,grp_var=grp,num_var4sort=amount,descending_or_not=1,dsdout=v6197o);
data v6197m(keep=metric value);set v6197o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6197m;set v6197m;format value best32.;run;
proc export data=v6197m outfile="%sysfunc(pathname(work))/V6197.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6197;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6197:;quit;
