/* New workflow V6232; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6232i;
length gene $80 grp $80 trait $80;
gene='id12';grp='g3';trait='t2';amount=246.11;output;
gene='id05';grp='g2';trait='t2';amount=493.04;output;
gene='id06';grp='g3';trait='t2';amount=386.05;output;
gene='id08';grp='g2';trait='t1';amount=959.07;output;
gene='id02';grp='g2';trait='t1';amount=635.01;output;
gene='id11';grp='g2';trait='t2';amount=15.1;output;
gene='id01';grp='g1';trait='t1';amount=351.0;output;
gene='id10';grp='g1';trait='t2';amount=691.09;output;
gene='id07';grp='g1';trait='t1';amount=698.06;output;
gene='id04';grp='g1';trait='t2';amount=500.03;output;
gene='id09';grp='g3';trait='t1';amount=376.08;output;
gene='id03';grp='g3';trait='t1';amount=226.02;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6232i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6232o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6232m(keep=metric value);set v6232o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6232m;set v6232m;format value best32.;run;
proc export data=v6232m outfile="%sysfunc(pathname(work))/V6232.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6232;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6232:;quit;
