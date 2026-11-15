/* New workflow V6189; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6189i;
length gene $80 grp $80 trait $80;
gene='id02';grp='g2';trait='t1';amount=79.01;output;
gene='id05';grp='g2';trait='t2';amount=527.04;output;
gene='id03';grp='g3';trait='t1';amount=792.02;output;
gene='id07';grp='g1';trait='t1';amount=55.06;output;
gene='id09';grp='g3';trait='t1';amount=149.08;output;
gene='id08';grp='g2';trait='t1';amount=965.07;output;
gene='id06';grp='g3';trait='t2';amount=378.05;output;
gene='id04';grp='g1';trait='t2';amount=296.03;output;
gene='id01';grp='g1';trait='t1';amount=658.0;output;
run;
%n26_number_rows_by_grp(dsdin=v6189i,grp_var=grp,num_var4sort=amount,descending_or_not=1,dsdout=v6189o);
data v6189m(keep=metric value);set v6189o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6189m;set v6189m;format value best32.;run;
proc export data=v6189m outfile="%sysfunc(pathname(work))/V6189.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6189;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6189:;quit;
