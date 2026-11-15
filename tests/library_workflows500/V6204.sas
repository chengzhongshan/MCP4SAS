/* New workflow V6204; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6204i;
length gene $80 grp $80 trait $80;
gene='id11';grp='g2';trait='t2';amount=374.1;output;
gene='id10';grp='g1';trait='t2';amount=823.09;output;
gene='id05';grp='g2';trait='t2';amount=987.04;output;
gene='id06';grp='g3';trait='t2';amount=118.05;output;
gene='id04';grp='g1';trait='t2';amount=657.03;output;
gene='id07';grp='g1';trait='t1';amount=802.06;output;
gene='id03';grp='g3';trait='t1';amount=877.02;output;
gene='id01';grp='g1';trait='t1';amount=970.0;output;
gene='id08';grp='g2';trait='t1';amount=880.07;output;
gene='id02';grp='g2';trait='t1';amount=855.01;output;
gene='id09';grp='g3';trait='t1';amount=753.08;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6204i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6204o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6204m(keep=metric value);set v6204o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6204m;set v6204m;format value best32.;run;
proc export data=v6204m outfile="%sysfunc(pathname(work))/V6204.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6204;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6204:;quit;
