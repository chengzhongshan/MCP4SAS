/* New workflow W6996; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6996i;
length gene $80;
gene='v01';x=0.0;y=0.49435729622403723;output;
gene='v02';x=0.3333333333333333;y=-0.7539448345250472;output;
gene='v03';x=0.6666666666666666;y=-0.1882673940007763;output;
gene='v04';x=1.0;y=0.3202271993355822;output;
gene='v05';x=1.3333333333333333;y=-0.1591552988261289;output;
gene='v06';x=1.6666666666666667;y=3.684429488437466;output;
gene='v07';x=2.0;y=4.41140201202077;output;
gene='v08';x=2.3333333333333335;y=2.3132206449193835;output;
gene='v09';x=2.6666666666666665;y=2.0718139021297857;output;
gene='v10';x=3.0;y=0.09562076307407752;output;
gene='v11';x=3.3333333333333335;y=3.0597047687578405;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6996" outputfmt=svg width=500px height=380px;title "W6996: synthetic SAS regression fixture";proc sgplot data=w6996i;scatter x=x y=y/markerattrs=(size=5);run;title;ods listing close;
data w6996m(keep=metric value);set w6996i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6996m;set w6996m;format value best32.;run;
proc export data=w6996m outfile="%sysfunc(pathname(work))/W6996.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6996;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6996:;quit;
