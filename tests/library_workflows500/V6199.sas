/* New workflow V6199; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6199i;
length gene $80 grp $80 trait $80;
gene='id01';grp='g1';trait='t1';amount=167.0;output;
gene='id11';grp='g2';trait='t2';amount=546.1;output;
gene='id05';grp='g2';trait='t2';amount=331.04;output;
gene='id03';grp='g3';trait='t1';amount=971.02;output;
gene='id09';grp='g3';trait='t1';amount=401.08;output;
gene='id12';grp='g3';trait='t2';amount=914.11;output;
gene='id08';grp='g2';trait='t1';amount=246.07;output;
gene='id07';grp='g1';trait='t1';amount=647.06;output;
gene='id04';grp='g1';trait='t2';amount=564.03;output;
gene='id06';grp='g3';trait='t2';amount=781.05;output;
gene='id02';grp='g2';trait='t1';amount=613.01;output;
gene='id10';grp='g1';trait='t2';amount=229.09;output;
run;
%n26_number_rows_by_grp(dsdin=v6199i,grp_var=grp,num_var4sort=amount,descending_or_not=1,dsdout=v6199o);
data v6199m(keep=metric value);set v6199o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6199m;set v6199m;format value best32.;run;
proc export data=v6199m outfile="%sysfunc(pathname(work))/V6199.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6199;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6199:;quit;
