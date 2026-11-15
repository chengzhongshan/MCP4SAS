/* New workflow V6207; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6207i;
length gene $80 grp $80 trait $80;
gene='id04';grp='g1';trait='t2';amount=420.03;output;
gene='id07';grp='g1';trait='t1';amount=98.06;output;
gene='id01';grp='g1';trait='t1';amount=667.0;output;
gene='id02';grp='g2';trait='t1';amount=52.01;output;
gene='id06';grp='g3';trait='t2';amount=935.05;output;
gene='id05';grp='g2';trait='t2';amount=311.04;output;
gene='id03';grp='g3';trait='t1';amount=34.02;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6207i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6207o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6207m(keep=metric value);set v6207o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6207m;set v6207m;format value best32.;run;
proc export data=v6207m outfile="%sysfunc(pathname(work))/V6207.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6207;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6207:;quit;
