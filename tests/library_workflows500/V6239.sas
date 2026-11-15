/* New workflow V6239; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6239i;
length gene $80 grp $80 trait $80;
gene='id02';grp='g2';trait='t1';amount=662.01;output;
gene='id05';grp='g2';trait='t2';amount=198.04;output;
gene='id01';grp='g1';trait='t1';amount=681.0;output;
gene='id06';grp='g3';trait='t2';amount=460.05;output;
gene='id04';grp='g1';trait='t2';amount=815.03;output;
gene='id09';grp='g3';trait='t1';amount=438.08;output;
gene='id11';grp='g2';trait='t2';amount=774.1;output;
gene='id10';grp='g1';trait='t2';amount=202.09;output;
gene='id03';grp='g3';trait='t1';amount=650.02;output;
gene='id07';grp='g1';trait='t1';amount=423.06;output;
gene='id08';grp='g2';trait='t1';amount=728.07;output;
gene='id12';grp='g3';trait='t2';amount=527.11;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6239i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6239o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6239m(keep=metric value);set v6239o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6239m;set v6239m;format value best32.;run;
proc export data=v6239m outfile="%sysfunc(pathname(work))/V6239.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6239;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6239:;quit;
