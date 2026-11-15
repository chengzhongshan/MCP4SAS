/* New workflow W6994; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6994i;
length gene $80;
gene='v01';x=0.0;y=1.581714476434501;output;
gene='v02';x=0.3333333333333333;y=3.864612698902299;output;
gene='v03';x=0.6666666666666666;y=3.1940920075957915;output;
gene='v04';x=1.0;y=2.1165650103865885;output;
gene='v05';x=1.3333333333333333;y=0.3950034235561841;output;
gene='v06';x=1.6666666666666667;y=1.4236025328371542;output;
gene='v07';x=2.0;y=-0.7184892719901119;output;
gene='v08';x=2.3333333333333335;y=1.9981409631115623;output;
gene='v09';x=2.6666666666666665;y=1.8830442369207723;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6994" outputfmt=svg width=580px height=410px;title "W6994: synthetic SAS regression fixture";proc sgplot data=w6994i;scatter x=x y=y/markerattrs=(size=8);run;title;ods listing close;
data w6994m(keep=metric value);set w6994i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6994m;set w6994m;format value best32.;run;
proc export data=w6994m outfile="%sysfunc(pathname(work))/W6994.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6994;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6994:;quit;
