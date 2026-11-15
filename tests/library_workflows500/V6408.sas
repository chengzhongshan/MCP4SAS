/* New workflow V6408; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6408i;
length gene $80;
gene='v01';pos=65;output;
gene='v02';pos=164;output;
gene='v03';pos=180;output;
gene='v04';pos=195;output;
run;
%n26_adjust_close_positions(indsd=v6408i,outdsd=v6408o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1080);
data v6408m(keep=metric value);set v6408o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6408m;set v6408m;format value best32.;run;
proc export data=v6408m outfile="%sysfunc(pathname(work))/V6408.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6408;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6408:;quit;
