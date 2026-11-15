/* New workflow W6999; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6999i;
length gene $80;
gene='v01';x=0.0;y=-0.17260561929301832;output;
gene='v02';x=0.3333333333333333;y=1.1648828899084787;output;
gene='v03';x=0.6666666666666666;y=1.9801022408902038;output;
gene='v04';x=1.0;y=-0.5014326106918873;output;
gene='v05';x=1.3333333333333333;y=3.6964919178533897;output;
gene='v06';x=1.6666666666666667;y=-0.32721417072587955;output;
gene='v07';x=2.0;y=1.6775254279379095;output;
gene='v08';x=2.3333333333333335;y=0.6874168910090495;output;
gene='v09';x=2.6666666666666665;y=4.947146480586211;output;
gene='v10';x=3.0;y=1.998267931633139;output;
gene='v11';x=3.3333333333333335;y=3.637225453607279;output;
gene='v12';x=3.6666666666666665;y=3.430711504261816;output;
gene='v13';x=4.0;y=4.7321283313906655;output;
gene='v14';x=4.333333333333333;y=2.808194298925451;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6999" outputfmt=svg width=620px height=380px;title "W6999: synthetic SAS regression fixture";proc sgplot data=w6999i;scatter x=x y=y/markerattrs=(size=8);run;title;ods listing close;
data w6999m(keep=metric value);set w6999i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6999m;set w6999m;format value best32.;run;
proc export data=w6999m outfile="%sysfunc(pathname(work))/W6999.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6999;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6999:;quit;
