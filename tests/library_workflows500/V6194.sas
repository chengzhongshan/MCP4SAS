/* New workflow V6194; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6194i;
length gene $80 grp $80 trait $80;
gene='id01';grp='g1';trait='t1';amount=480.0;output;
gene='id07';grp='g1';trait='t1';amount=112.06;output;
gene='id02';grp='g2';trait='t1';amount=685.01;output;
gene='id04';grp='g1';trait='t2';amount=833.03;output;
gene='id03';grp='g3';trait='t1';amount=271.02;output;
gene='id05';grp='g2';trait='t2';amount=384.04;output;
gene='id06';grp='g3';trait='t2';amount=570.05;output;
run;
%n26_number_rows_by_grp(dsdin=v6194i,grp_var=grp,num_var4sort=amount,descending_or_not=0,dsdout=v6194o);
data v6194m(keep=metric value);set v6194o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6194m;set v6194m;format value best32.;run;
proc export data=v6194m outfile="%sysfunc(pathname(work))/V6194.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6194;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6194:;quit;
