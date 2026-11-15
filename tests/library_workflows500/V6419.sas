/* New workflow V6419; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6419i;
length gene $80;
gene='v01';pos=8;output;
gene='v02';pos=32;output;
gene='v03';pos=41;output;
gene='v04';pos=79;output;
gene='v05';pos=81;output;
gene='v06';pos=83;output;
gene='v07';pos=156;output;
gene='v08';pos=191;output;
run;
%n26_adjust_close_positions(indsd=v6419i,outdsd=v6419o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1190);
data v6419m(keep=metric value);set v6419o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6419m;set v6419m;format value best32.;run;
proc export data=v6419m outfile="%sysfunc(pathname(work))/V6419.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6419;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6419:;quit;
