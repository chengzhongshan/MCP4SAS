/* New workflow V6243; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6243i;
length gene $80 grp $80 trait $80;
gene='id05';grp='g2';trait='t2';amount=275.04;output;
gene='id03';grp='g3';trait='t1';amount=38.02;output;
gene='id10';grp='g1';trait='t2';amount=941.09;output;
gene='id09';grp='g3';trait='t1';amount=198.08;output;
gene='id01';grp='g1';trait='t1';amount=421.0;output;
gene='id02';grp='g2';trait='t1';amount=521.01;output;
gene='id07';grp='g1';trait='t1';amount=90.06;output;
gene='id06';grp='g3';trait='t2';amount=317.05;output;
gene='id08';grp='g2';trait='t1';amount=151.07;output;
gene='id04';grp='g1';trait='t2';amount=320.03;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6243i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6243o,num_grp_output_name=code);
data v6243m(keep=metric value);set v6243o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6243m;set v6243m;format value best32.;run;
proc export data=v6243m outfile="%sysfunc(pathname(work))/V6243.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6243;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6243:;quit;
