/* New workflow V6226; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6226i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=992.02;output;
gene='id12';grp='g3';trait='t2';amount=855.11;output;
gene='id04';grp='g1';trait='t2';amount=410.03;output;
gene='id07';grp='g1';trait='t1';amount=315.06;output;
gene='id01';grp='g1';trait='t1';amount=108.0;output;
gene='id06';grp='g3';trait='t2';amount=881.05;output;
gene='id11';grp='g2';trait='t2';amount=258.1;output;
gene='id05';grp='g2';trait='t2';amount=875.04;output;
gene='id08';grp='g2';trait='t1';amount=238.07;output;
gene='id09';grp='g3';trait='t1';amount=989.08;output;
gene='id02';grp='g2';trait='t1';amount=917.01;output;
gene='id10';grp='g1';trait='t2';amount=395.09;output;
gene='id13';grp='g1';trait='t1';amount=655.12;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6226i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6226o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6226m(keep=metric value);set v6226o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6226m;set v6226m;format value best32.;run;
proc export data=v6226m outfile="%sysfunc(pathname(work))/V6226.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6226;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6226:;quit;
