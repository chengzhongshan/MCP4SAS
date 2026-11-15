/* New workflow V6190; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6190i;
length gene $80 grp $80 trait $80;
gene='id02';grp='g2';trait='t1';amount=373.01;output;
gene='id08';grp='g2';trait='t1';amount=148.07;output;
gene='id09';grp='g3';trait='t1';amount=25.08;output;
gene='id10';grp='g1';trait='t2';amount=581.09;output;
gene='id04';grp='g1';trait='t2';amount=767.03;output;
gene='id06';grp='g3';trait='t2';amount=404.05;output;
gene='id03';grp='g3';trait='t1';amount=483.02;output;
gene='id01';grp='g1';trait='t1';amount=81.0;output;
gene='id07';grp='g1';trait='t1';amount=726.06;output;
gene='id05';grp='g2';trait='t2';amount=772.04;output;
run;
%n26_number_rows_by_grp(dsdin=v6190i,grp_var=grp,num_var4sort=amount,descending_or_not=0,dsdout=v6190o);
data v6190m(keep=metric value);set v6190o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6190m;set v6190m;format value best32.;run;
proc export data=v6190m outfile="%sysfunc(pathname(work))/V6190.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6190;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6190:;quit;
