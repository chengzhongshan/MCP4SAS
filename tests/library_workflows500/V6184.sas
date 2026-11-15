/* New workflow V6184; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6184i;
length gene $80 grp $80 trait $80;
gene='id10';grp='g1';trait='t2';amount=208.09;output;
gene='id11';grp='g2';trait='t2';amount=671.1;output;
gene='id01';grp='g1';trait='t1';amount=956.0;output;
gene='id06';grp='g3';trait='t2';amount=664.05;output;
gene='id09';grp='g3';trait='t1';amount=871.08;output;
gene='id03';grp='g3';trait='t1';amount=422.02;output;
gene='id07';grp='g1';trait='t1';amount=357.06;output;
gene='id05';grp='g2';trait='t2';amount=973.04;output;
gene='id04';grp='g1';trait='t2';amount=614.03;output;
gene='id08';grp='g2';trait='t1';amount=695.07;output;
gene='id02';grp='g2';trait='t1';amount=934.01;output;
run;
%n26_number_rows_by_grp(dsdin=v6184i,grp_var=grp,num_var4sort=amount,descending_or_not=0,dsdout=v6184o);
data v6184m(keep=metric value);set v6184o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6184m;set v6184m;format value best32.;run;
proc export data=v6184m outfile="%sysfunc(pathname(work))/V6184.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6184;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6184:;quit;
