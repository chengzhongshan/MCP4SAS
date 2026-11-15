/* New workflow W6988; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6988i;
length gene $80;
gene='v01';x=0.0;y=1.4878368011075995;output;
gene='v02';x=0.3333333333333333;y=0.5836779849274618;output;
gene='v03';x=0.6666666666666666;y=0.8055529106307403;output;
gene='v04';x=1.0;y=0.2590926366393912;output;
gene='v05';x=1.3333333333333333;y=0.08294951157113362;output;
gene='v06';x=1.6666666666666667;y=3.263101432984188;output;
gene='v07';x=2.0;y=4.87323616613312;output;
gene='v08';x=2.3333333333333335;y=3.8531797627259468;output;
gene='v09';x=2.6666666666666665;y=4.491213672843967;output;
gene='v10';x=3.0;y=1.107765743324812;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6988" outputfmt=svg width=500px height=410px;title "W6988: synthetic SAS regression fixture";proc sgplot data=w6988i;scatter x=x y=y/markerattrs=(size=7);run;title;ods listing close;
data w6988m(keep=metric value);set w6988i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6988m;set w6988m;format value best32.;run;
proc export data=w6988m outfile="%sysfunc(pathname(work))/W6988.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6988;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6988:;quit;
