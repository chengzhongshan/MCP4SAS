/* New workflow V6185; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6185i;
length gene $80 grp $80 trait $80;
gene='id07';grp='g1';trait='t1';amount=842.06;output;
gene='id01';grp='g1';trait='t1';amount=448.0;output;
gene='id11';grp='g2';trait='t2';amount=27.1;output;
gene='id03';grp='g3';trait='t1';amount=356.02;output;
gene='id02';grp='g2';trait='t1';amount=615.01;output;
gene='id08';grp='g2';trait='t1';amount=6.07;output;
gene='id12';grp='g3';trait='t2';amount=422.11;output;
gene='id09';grp='g3';trait='t1';amount=621.08;output;
gene='id06';grp='g3';trait='t2';amount=852.05;output;
gene='id05';grp='g2';trait='t2';amount=119.04;output;
gene='id10';grp='g1';trait='t2';amount=574.09;output;
gene='id04';grp='g1';trait='t2';amount=501.03;output;
run;
%n26_number_rows_by_grp(dsdin=v6185i,grp_var=grp,num_var4sort=amount,descending_or_not=1,dsdout=v6185o);
data v6185m(keep=metric value);set v6185o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6185m;set v6185m;format value best32.;run;
proc export data=v6185m outfile="%sysfunc(pathname(work))/V6185.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6185;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6185:;quit;
