/* New workflow V6183; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6183i;
length gene $80 grp $80 trait $80;
gene='id04';grp='g1';trait='t2';amount=575.03;output;
gene='id02';grp='g2';trait='t1';amount=758.01;output;
gene='id01';grp='g1';trait='t1';amount=114.0;output;
gene='id03';grp='g3';trait='t1';amount=679.02;output;
gene='id10';grp='g1';trait='t2';amount=383.09;output;
gene='id09';grp='g3';trait='t1';amount=670.08;output;
gene='id08';grp='g2';trait='t1';amount=172.07;output;
gene='id05';grp='g2';trait='t2';amount=687.04;output;
gene='id07';grp='g1';trait='t1';amount=430.06;output;
gene='id06';grp='g3';trait='t2';amount=609.05;output;
run;
%n26_number_rows_by_grp(dsdin=v6183i,grp_var=grp,num_var4sort=amount,descending_or_not=1,dsdout=v6183o);
data v6183m(keep=metric value);set v6183o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6183m;set v6183m;format value best32.;run;
proc export data=v6183m outfile="%sysfunc(pathname(work))/V6183.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6183;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6183:;quit;
