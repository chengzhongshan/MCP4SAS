/* New workflow V6416; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6416i;
length gene $80;
gene='v01';pos=7;output;
gene='v02';pos=9;output;
gene='v03';pos=101;output;
gene='v04';pos=127;output;
gene='v05';pos=237;output;
run;
%n26_adjust_close_positions(indsd=v6416i,outdsd=v6416o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1160);
data v6416m(keep=metric value);set v6416o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6416m;set v6416m;format value best32.;run;
proc export data=v6416m outfile="%sysfunc(pathname(work))/V6416.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6416;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6416:;quit;
