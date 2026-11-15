/* New workflow V6273; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6273i;
length gene $80;
gene='allele01';ref=19;alt=22;output;
gene='allele02';ref=25;alt=12;output;
gene='allele03';ref=17;alt=8;output;
gene='allele04';ref=12;alt=40;output;
gene='allele05';ref=18;alt=27;output;
gene='allele06';ref=32;alt=17;output;
gene='allele07';ref=33;alt=7;output;
gene='allele08';ref=26;alt=4;output;
gene='allele09';ref=17;alt=21;output;
run;
%n26_calculate_binomial_P(dsdin=v6273i,dsdout=v6273o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=6);
data v6273m(keep=metric value);set v6273o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6273m;set v6273m;format value best32.;run;
proc export data=v6273m outfile="%sysfunc(pathname(work))/V6273.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6273;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6273:;quit;
