/* New workflow W6992; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6992i;
length gene $80;
gene='v01';x=0.0;y=-1.0532344163476508;output;
gene='v02';x=0.3333333333333333;y=-1.7154177182464587;output;
gene='v03';x=0.6666666666666666;y=3.3964236835175243;output;
gene='v04';x=1.0;y=4.059828052663485;output;
gene='v05';x=1.3333333333333333;y=4.795667763861241;output;
gene='v06';x=1.6666666666666667;y=3.5598645066893075;output;
gene='v07';x=2.0;y=-0.5489704826200101;output;
gene='v08';x=2.3333333333333335;y=3.4754328520534483;output;
gene='v09';x=2.6666666666666665;y=3.876785131699464;output;
gene='v10';x=3.0;y=0.9994232864559893;output;
gene='v11';x=3.3333333333333335;y=4.968240413610149;output;
gene='v12';x=3.6666666666666665;y=1.0205368620595971;output;
gene='v13';x=4.0;y=5.418859168611474;output;
gene='v14';x=4.333333333333333;y=3.961111618396123;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6992" outputfmt=svg width=500px height=350px;title "W6992: synthetic SAS regression fixture";proc sgplot data=w6992i;scatter x=x y=y/markerattrs=(size=6);run;title;ods listing close;
data w6992m(keep=metric value);set w6992i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6992m;set w6992m;format value best32.;run;
proc export data=w6992m outfile="%sysfunc(pathname(work))/W6992.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6992;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6992:;quit;
