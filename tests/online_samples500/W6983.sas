/* New workflow W6983; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6983i;
length gene $80;
gene='v01';x=0.0;y=3.4187171152286098;output;
gene='v02';x=0.3333333333333333;y=-1.2703005105744425;output;
gene='v03';x=0.6666666666666666;y=3.7626313730062253;output;
gene='v04';x=1.0;y=-0.7143062411993789;output;
gene='v05';x=1.3333333333333333;y=4.379501620678113;output;
gene='v06';x=1.6666666666666667;y=3.219220920583287;output;
gene='v07';x=2.0;y=3.883730068190773;output;
gene='v08';x=2.3333333333333335;y=1.6999721994314525;output;
gene='v09';x=2.6666666666666665;y=3.121829672997881;output;
gene='v10';x=3.0;y=0.9311872841189659;output;
gene='v11';x=3.3333333333333335;y=5.9075081578371735;output;
gene='v12';x=3.6666666666666665;y=2.58767804146083;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6983" outputfmt=svg width=620px height=350px;title "W6983: synthetic SAS regression fixture";proc sgplot data=w6983i;scatter x=x y=y/markerattrs=(size=7);run;title;ods listing close;
data w6983m(keep=metric value);set w6983i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6983m;set w6983m;format value best32.;run;
proc export data=w6983m outfile="%sysfunc(pathname(work))/W6983.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6983;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6983:;quit;
