/* New workflow V6229; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6229i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=49.02;output;
gene='id08';grp='g2';trait='t1';amount=643.07;output;
gene='id01';grp='g1';trait='t1';amount=285.0;output;
gene='id07';grp='g1';trait='t1';amount=76.06;output;
gene='id09';grp='g3';trait='t1';amount=420.08;output;
gene='id02';grp='g2';trait='t1';amount=109.01;output;
gene='id06';grp='g3';trait='t2';amount=247.05;output;
gene='id04';grp='g1';trait='t2';amount=146.03;output;
gene='id05';grp='g2';trait='t2';amount=97.04;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6229i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6229o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6229m(keep=metric value);set v6229o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6229m;set v6229m;format value best32.;run;
proc export data=v6229m outfile="%sysfunc(pathname(work))/V6229.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6229;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6229:;quit;
