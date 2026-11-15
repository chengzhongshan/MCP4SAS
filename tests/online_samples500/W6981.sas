/* New workflow W6981; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6981i;
length gene $80;
gene='v01';x=0.0;y=1.6236884467571544;output;
gene='v02';x=0.3333333333333333;y=0.18687394257329;output;
gene='v03';x=0.6666666666666666;y=1.6999659136952188;output;
gene='v04';x=1.0;y=3.1363690740020984;output;
gene='v05';x=1.3333333333333333;y=0.3642209303184214;output;
gene='v06';x=1.6666666666666667;y=-0.7920873659041041;output;
gene='v07';x=2.0;y=-0.7371707820456483;output;
gene='v08';x=2.3333333333333335;y=0.9661383416573597;output;
gene='v09';x=2.6666666666666665;y=2.2360689887498846;output;
gene='v10';x=3.0;y=5.460281756552449;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6981" outputfmt=svg width=540px height=380px;title "W6981: synthetic SAS regression fixture";proc sgplot data=w6981i;scatter x=x y=y/markerattrs=(size=5);run;title;ods listing close;
data w6981m(keep=metric value);set w6981i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6981m;set w6981m;format value best32.;run;
proc export data=w6981m outfile="%sysfunc(pathname(work))/W6981.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6981;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6981:;quit;
