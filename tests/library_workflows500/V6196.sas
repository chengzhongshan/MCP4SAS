/* New workflow V6196; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6196i;
length gene $80 grp $80 trait $80;
gene='id08';grp='g2';trait='t1';amount=104.07;output;
gene='id03';grp='g3';trait='t1';amount=71.02;output;
gene='id04';grp='g1';trait='t2';amount=584.03;output;
gene='id06';grp='g3';trait='t2';amount=596.05;output;
gene='id07';grp='g1';trait='t1';amount=488.06;output;
gene='id09';grp='g3';trait='t1';amount=144.08;output;
gene='id02';grp='g2';trait='t1';amount=632.01;output;
gene='id01';grp='g1';trait='t1';amount=48.0;output;
gene='id05';grp='g2';trait='t2';amount=443.04;output;
run;
%n26_number_rows_by_grp(dsdin=v6196i,grp_var=grp,num_var4sort=amount,descending_or_not=0,dsdout=v6196o);
data v6196m(keep=metric value);set v6196o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6196m;set v6196m;format value best32.;run;
proc export data=v6196m outfile="%sysfunc(pathname(work))/V6196.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6196;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6196:;quit;
