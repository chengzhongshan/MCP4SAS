/* New workflow V6182; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6182i;
length gene $80 grp $80 trait $80;
gene='id05';grp='g2';trait='t2';amount=205.04;output;
gene='id01';grp='g1';trait='t1';amount=918.0;output;
gene='id06';grp='g3';trait='t2';amount=529.05;output;
gene='id09';grp='g3';trait='t1';amount=667.08;output;
gene='id04';grp='g1';trait='t2';amount=267.03;output;
gene='id02';grp='g2';trait='t1';amount=655.01;output;
gene='id07';grp='g1';trait='t1';amount=588.06;output;
gene='id08';grp='g2';trait='t1';amount=429.07;output;
gene='id03';grp='g3';trait='t1';amount=488.02;output;
run;
%n26_number_rows_by_grp(dsdin=v6182i,grp_var=grp,num_var4sort=amount,descending_or_not=0,dsdout=v6182o);
data v6182m(keep=metric value);set v6182o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6182m;set v6182m;format value best32.;run;
proc export data=v6182m outfile="%sysfunc(pathname(work))/V6182.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6182;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6182:;quit;
