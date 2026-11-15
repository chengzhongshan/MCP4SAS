/* New workflow V6195; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6195i;
length gene $80 grp $80 trait $80;
gene='id07';grp='g1';trait='t1';amount=992.06;output;
gene='id05';grp='g2';trait='t2';amount=287.04;output;
gene='id01';grp='g1';trait='t1';amount=243.0;output;
gene='id08';grp='g2';trait='t1';amount=890.07;output;
gene='id04';grp='g1';trait='t2';amount=151.03;output;
gene='id03';grp='g3';trait='t1';amount=551.02;output;
gene='id02';grp='g2';trait='t1';amount=973.01;output;
gene='id06';grp='g3';trait='t2';amount=20.05;output;
run;
%n26_number_rows_by_grp(dsdin=v6195i,grp_var=grp,num_var4sort=amount,descending_or_not=1,dsdout=v6195o);
data v6195m(keep=metric value);set v6195o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6195m;set v6195m;format value best32.;run;
proc export data=v6195m outfile="%sysfunc(pathname(work))/V6195.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6195;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6195:;quit;
