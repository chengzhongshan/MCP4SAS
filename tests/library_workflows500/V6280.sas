/* New workflow V6280; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6280i;
length gene $80;
gene='allele01';ref=40;alt=31;output;
gene='allele02';ref=36;alt=35;output;
gene='allele03';ref=35;alt=12;output;
gene='allele04';ref=14;alt=28;output;
gene='allele05';ref=19;alt=35;output;
gene='allele06';ref=28;alt=38;output;
gene='allele07';ref=10;alt=26;output;
gene='allele08';ref=15;alt=30;output;
gene='allele09';ref=0;alt=4;output;
run;
%n26_calculate_binomial_P(dsdin=v6280i,dsdout=v6280o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=4);
data v6280m(keep=metric value);set v6280o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6280m;set v6280m;format value best32.;run;
proc export data=v6280m outfile="%sysfunc(pathname(work))/V6280.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6280;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6280:;quit;
