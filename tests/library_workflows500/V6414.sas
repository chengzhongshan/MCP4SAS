/* New workflow V6414; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6414i;
length gene $80;
gene='v01';pos=43;output;
gene='v02';pos=122;output;
gene='v03';pos=204;output;
run;
%n26_adjust_close_positions(indsd=v6414i,outdsd=v6414o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1140);
data v6414m(keep=metric value);set v6414o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6414m;set v6414m;format value best32.;run;
proc export data=v6414m outfile="%sysfunc(pathname(work))/V6414.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6414;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6414:;quit;
