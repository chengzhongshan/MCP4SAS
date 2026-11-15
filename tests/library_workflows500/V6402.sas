/* New workflow V6402; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6402i;
length gene $80;
gene='v01';pos=27;output;
gene='v02';pos=28;output;
gene='v03';pos=52;output;
gene='v04';pos=80;output;
gene='v05';pos=169;output;
run;
%n26_adjust_close_positions(indsd=v6402i,outdsd=v6402o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1020);
data v6402m(keep=metric value);set v6402o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6402m;set v6402m;format value best32.;run;
proc export data=v6402m outfile="%sysfunc(pathname(work))/V6402.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6402;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6402:;quit;
