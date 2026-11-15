/* New workflow V6181; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6181i;
length gene $80 grp $80 trait $80;
gene='id01';grp='g1';trait='t1';amount=968.0;output;
gene='id04';grp='g1';trait='t2';amount=761.03;output;
gene='id08';grp='g2';trait='t1';amount=908.07;output;
gene='id05';grp='g2';trait='t2';amount=111.04;output;
gene='id02';grp='g2';trait='t1';amount=766.01;output;
gene='id06';grp='g3';trait='t2';amount=961.05;output;
gene='id03';grp='g3';trait='t1';amount=671.02;output;
gene='id07';grp='g1';trait='t1';amount=400.06;output;
run;
%n26_number_rows_by_grp(dsdin=v6181i,grp_var=grp,num_var4sort=amount,descending_or_not=1,dsdout=v6181o);
data v6181m(keep=metric value);set v6181o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6181m;set v6181m;format value best32.;run;
proc export data=v6181m outfile="%sysfunc(pathname(work))/V6181.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6181;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6181:;quit;
