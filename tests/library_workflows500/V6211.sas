/* New workflow V6211; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6211i;
length gene $80 grp $80 trait $80;
gene='id08';grp='g2';trait='t1';amount=410.07;output;
gene='id09';grp='g3';trait='t1';amount=24.08;output;
gene='id10';grp='g1';trait='t2';amount=330.09;output;
gene='id07';grp='g1';trait='t1';amount=218.06;output;
gene='id03';grp='g3';trait='t1';amount=468.02;output;
gene='id05';grp='g2';trait='t2';amount=419.04;output;
gene='id11';grp='g2';trait='t2';amount=508.1;output;
gene='id02';grp='g2';trait='t1';amount=272.01;output;
gene='id01';grp='g1';trait='t1';amount=769.0;output;
gene='id06';grp='g3';trait='t2';amount=330.05;output;
gene='id04';grp='g1';trait='t2';amount=12.03;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6211i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6211o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6211m(keep=metric value);set v6211o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6211m;set v6211m;format value best32.;run;
proc export data=v6211m outfile="%sysfunc(pathname(work))/V6211.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6211;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6211:;quit;
