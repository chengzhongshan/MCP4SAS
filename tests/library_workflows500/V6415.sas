/* New workflow V6415; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6415i;
length gene $80;
gene='v01';pos=15;output;
gene='v02';pos=36;output;
gene='v03';pos=212;output;
gene='v04';pos=239;output;
run;
%n26_adjust_close_positions(indsd=v6415i,outdsd=v6415o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1150);
data v6415m(keep=metric value);set v6415o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6415m;set v6415m;format value best32.;run;
proc export data=v6415m outfile="%sysfunc(pathname(work))/V6415.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6415;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6415:;quit;
