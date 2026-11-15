/* New workflow V6193; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6193i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=306.05;output;
gene='id08';grp='g2';trait='t1';amount=571.07;output;
gene='id03';grp='g3';trait='t1';amount=738.02;output;
gene='id07';grp='g1';trait='t1';amount=943.06;output;
gene='id02';grp='g2';trait='t1';amount=193.01;output;
gene='id11';grp='g2';trait='t2';amount=523.1;output;
gene='id09';grp='g3';trait='t1';amount=54.08;output;
gene='id01';grp='g1';trait='t1';amount=818.0;output;
gene='id05';grp='g2';trait='t2';amount=380.04;output;
gene='id12';grp='g3';trait='t2';amount=795.11;output;
gene='id10';grp='g1';trait='t2';amount=376.09;output;
gene='id04';grp='g1';trait='t2';amount=414.03;output;
gene='id13';grp='g1';trait='t1';amount=150.12;output;
run;
%n26_number_rows_by_grp(dsdin=v6193i,grp_var=grp,num_var4sort=amount,descending_or_not=1,dsdout=v6193o);
data v6193m(keep=metric value);set v6193o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6193m;set v6193m;format value best32.;run;
proc export data=v6193m outfile="%sysfunc(pathname(work))/V6193.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6193;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6193:;quit;
