/* New workflow W6982; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6982i;
length gene $80;
gene='v01';x=0.0;y=0.05850064619257589;output;
gene='v02';x=0.3333333333333333;y=-1.2676636291291357;output;
gene='v03';x=0.6666666666666666;y=2.273882835505412;output;
gene='v04';x=1.0;y=-0.5092545147180346;output;
gene='v05';x=1.3333333333333333;y=0.5244629552961009;output;
gene='v06';x=1.6666666666666667;y=1.4908684084561798;output;
gene='v07';x=2.0;y=-0.7328906302779032;output;
gene='v08';x=2.3333333333333335;y=5.284025863707932;output;
gene='v09';x=2.6666666666666665;y=5.580001096632309;output;
gene='v10';x=3.0;y=5.771127900963045;output;
gene='v11';x=3.3333333333333335;y=3.376791596023775;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6982" outputfmt=svg width=580px height=410px;title "W6982: synthetic SAS regression fixture";proc sgplot data=w6982i;scatter x=x y=y/markerattrs=(size=6);run;title;ods listing close;
data w6982m(keep=metric value);set w6982i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6982m;set w6982m;format value best32.;run;
proc export data=w6982m outfile="%sysfunc(pathname(work))/W6982.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6982;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6982:;quit;
