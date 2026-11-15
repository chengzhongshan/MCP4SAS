/* New workflow V6187; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6187i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=92.02;output;
gene='id02';grp='g2';trait='t1';amount=147.01;output;
gene='id04';grp='g1';trait='t2';amount=982.03;output;
gene='id05';grp='g2';trait='t2';amount=460.04;output;
gene='id07';grp='g1';trait='t1';amount=919.06;output;
gene='id06';grp='g3';trait='t2';amount=408.05;output;
gene='id01';grp='g1';trait='t1';amount=961.0;output;
run;
%n26_number_rows_by_grp(dsdin=v6187i,grp_var=grp,num_var4sort=amount,descending_or_not=1,dsdout=v6187o);
data v6187m(keep=metric value);set v6187o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6187m;set v6187m;format value best32.;run;
proc export data=v6187m outfile="%sysfunc(pathname(work))/V6187.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6187;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6187:;quit;
