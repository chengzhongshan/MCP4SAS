/* Test-only namespaced definition from calculate_binomial_P.sas; original SHA256 b28f41aab2e06e803debf8afd539fab544740f61ee331dc702c517ad5d49691d. */
%macro n26_calculate_binomial_P(
dsdin=_last_,	/*SAS input data set for calculating binomial P*/
dsdout=,	/*output sas data set that contains the newly created binomial_P and its -logP*/
Allele1_var=V1,/*Counts for variable allele 1, usually the ref allele, such as allele 1 in ASE*/
Allele2_var=V2,/*Counts for variable allele 2, such as alele 2 in ASE*/
TotReadCutoff=20,/*Total read counts cutoff, used to delete records with total reads of alleles <= the cutoff*/
Abs_A1A2_ratio_cutoff=10,/*the largest value allowable for the absolute ratio between alele 1 and 2, with value >10 or <-10 will be assigned with value 10*/
Largest_logP=500 /*When the binomial P is too significantly close to 0, the -log(P) would be arbitarily given the value 500*/
);

data &dsdout;
set &dsdin;
tot_reads=&Allele1_var+&Allele2_var;
if tot_reads<&TotReadCutoff then delete;
A1A2log2Ratio=log2((&Allele1_var+0.0001)/(&Allele2_var+0.0001));
if A1A2log2Ratio>&Abs_A1A2_ratio_cutoff then A1A2log2Ratio=10;
else if A1A2log2Ratio<-&Abs_A1A2_ratio_cutoff then A1A2log2Ratio=-10;
Ref_Frq=100*(&Allele1_var/(tot_reads));
/*Make sure to use the smallest num for calculating bionomial P*/
if &Allele1_var-&Allele2_var>0 then do;
  binomial_P=probbnml(0.5,tot_reads,&Allele2_var+0);
end;
else do;
  binomial_P=probbnml(0.5,tot_reads,&Allele1_var+0);
end;

if (binomial_P=0) then do;
logP=500;
end;
else do;
logP=-log10(binomial_P);
end;

run;

%mend;
