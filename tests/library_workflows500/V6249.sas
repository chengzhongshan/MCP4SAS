/* New workflow V6249; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6249i;
length gene $80 grp $80 trait $80;
gene='id07';grp='g1';trait='t1';amount=51.06;output;
gene='id05';grp='g2';trait='t2';amount=196.04;output;
gene='id02';grp='g2';trait='t1';amount=562.01;output;
gene='id04';grp='g1';trait='t2';amount=786.03;output;
gene='id09';grp='g3';trait='t1';amount=494.08;output;
gene='id06';grp='g3';trait='t2';amount=97.05;output;
gene='id08';grp='g2';trait='t1';amount=325.07;output;
gene='id03';grp='g3';trait='t1';amount=699.02;output;
gene='id01';grp='g1';trait='t1';amount=257.0;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6249i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6249o,num_grp_output_name=code);
data v6249m(keep=metric value);set v6249o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6249m;set v6249m;format value best32.;run;
proc export data=v6249m outfile="%sysfunc(pathname(work))/V6249.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6249;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6249:;quit;
