/* New workflow V6250; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6250i;
length gene $80 grp $80 trait $80;
gene='id09';grp='g3';trait='t1';amount=612.08;output;
gene='id03';grp='g3';trait='t1';amount=771.02;output;
gene='id01';grp='g1';trait='t1';amount=786.0;output;
gene='id10';grp='g1';trait='t2';amount=565.09;output;
gene='id02';grp='g2';trait='t1';amount=214.01;output;
gene='id06';grp='g3';trait='t2';amount=715.05;output;
gene='id05';grp='g2';trait='t2';amount=443.04;output;
gene='id07';grp='g1';trait='t1';amount=309.06;output;
gene='id08';grp='g2';trait='t1';amount=32.07;output;
gene='id04';grp='g1';trait='t2';amount=526.03;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6250i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6250o,num_grp_output_name=code);
data v6250m(keep=metric value);set v6250o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6250m;set v6250m;format value best32.;run;
proc export data=v6250m outfile="%sysfunc(pathname(work))/V6250.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6250;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6250:;quit;
