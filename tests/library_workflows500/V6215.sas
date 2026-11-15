/* New workflow V6215; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6215i;
length gene $80 grp $80 trait $80;
gene='id08';grp='g2';trait='t1';amount=195.07;output;
gene='id07';grp='g1';trait='t1';amount=234.06;output;
gene='id06';grp='g3';trait='t2';amount=289.05;output;
gene='id04';grp='g1';trait='t2';amount=386.03;output;
gene='id01';grp='g1';trait='t1';amount=33.0;output;
gene='id02';grp='g2';trait='t1';amount=869.01;output;
gene='id05';grp='g2';trait='t2';amount=138.04;output;
gene='id03';grp='g3';trait='t1';amount=51.02;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6215i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6215o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6215m(keep=metric value);set v6215o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6215m;set v6215m;format value best32.;run;
proc export data=v6215m outfile="%sysfunc(pathname(work))/V6215.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6215;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6215:;quit;
