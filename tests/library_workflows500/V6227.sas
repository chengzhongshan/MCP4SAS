/* New workflow V6227; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6227i;
length gene $80 grp $80 trait $80;
gene='id07';grp='g1';trait='t1';amount=130.06;output;
gene='id01';grp='g1';trait='t1';amount=18.0;output;
gene='id05';grp='g2';trait='t2';amount=422.04;output;
gene='id06';grp='g3';trait='t2';amount=274.05;output;
gene='id04';grp='g1';trait='t2';amount=695.03;output;
gene='id02';grp='g2';trait='t1';amount=773.01;output;
gene='id03';grp='g3';trait='t1';amount=745.02;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6227i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6227o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6227m(keep=metric value);set v6227o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6227m;set v6227m;format value best32.;run;
proc export data=v6227m outfile="%sysfunc(pathname(work))/V6227.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6227;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6227:;quit;
