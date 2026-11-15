/* New workflow W6991; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6991i;
length gene $80;
gene='v01';x=0.0;y=0.7597013702295552;output;
gene='v02';x=0.3333333333333333;y=-0.300253721911065;output;
gene='v03';x=0.6666666666666666;y=3.01303506362594;output;
gene='v04';x=1.0;y=2.018323792819564;output;
gene='v05';x=1.3333333333333333;y=0.22097975948389292;output;
gene='v06';x=1.6666666666666667;y=4.505661692170842;output;
gene='v07';x=2.0;y=-0.5563748503526609;output;
gene='v08';x=2.3333333333333335;y=1.4464966829309005;output;
gene='v09';x=2.6666666666666665;y=2.813826288401041;output;
gene='v10';x=3.0;y=3.649959712767603;output;
gene='v11';x=3.3333333333333335;y=1.3781053218279777;output;
gene='v12';x=3.6666666666666665;y=6.194538854797815;output;
gene='v13';x=4.0;y=2.351467120214041;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6991" outputfmt=svg width=620px height=410px;title "W6991: synthetic SAS regression fixture";proc sgplot data=w6991i;scatter x=x y=y/markerattrs=(size=5);run;title;ods listing close;
data w6991m(keep=metric value);set w6991i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6991m;set w6991m;format value best32.;run;
proc export data=w6991m outfile="%sysfunc(pathname(work))/W6991.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6991;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6991:;quit;
