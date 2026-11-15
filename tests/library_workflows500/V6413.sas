/* New workflow V6413; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6413i;
length gene $80;
gene='v01';pos=11;output;
gene='v02';pos=95;output;
gene='v03';pos=117;output;
gene='v04';pos=134;output;
gene='v05';pos=181;output;
gene='v06';pos=197;output;
gene='v07';pos=208;output;
gene='v08';pos=225;output;
gene='v09';pos=228;output;
run;
%n26_adjust_close_positions(indsd=v6413i,outdsd=v6413o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1130);
data v6413m(keep=metric value);set v6413o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6413m;set v6413m;format value best32.;run;
proc export data=v6413m outfile="%sysfunc(pathname(work))/V6413.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6413;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6413:;quit;
