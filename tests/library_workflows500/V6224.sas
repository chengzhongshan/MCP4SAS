/* New workflow V6224; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6224i;
length gene $80 grp $80 trait $80;
gene='id05';grp='g2';trait='t2';amount=976.04;output;
gene='id02';grp='g2';trait='t1';amount=22.01;output;
gene='id09';grp='g3';trait='t1';amount=318.08;output;
gene='id04';grp='g1';trait='t2';amount=594.03;output;
gene='id01';grp='g1';trait='t1';amount=253.0;output;
gene='id06';grp='g3';trait='t2';amount=165.05;output;
gene='id03';grp='g3';trait='t1';amount=396.02;output;
gene='id08';grp='g2';trait='t1';amount=21.07;output;
gene='id10';grp='g1';trait='t2';amount=133.09;output;
gene='id11';grp='g2';trait='t2';amount=438.1;output;
gene='id07';grp='g1';trait='t1';amount=773.06;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6224i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6224o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6224m(keep=metric value);set v6224o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6224m;set v6224m;format value best32.;run;
proc export data=v6224m outfile="%sysfunc(pathname(work))/V6224.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6224;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6224:;quit;
