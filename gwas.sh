#!/bin/bash
cmd="sbatch --time=3-0:00:00 --mem=80g"

#############################################################################################################
#############################################################################################################
#############################################################################################################

#Only modify stuff up here, please

#Enter the path and name for your phenotype file
file_pheno="~/phenofile.050619"

#Enter the name of your outcome variable
outcome_variable="outcome1"

#Enter the name of your covariates
covariate_variable="pop"
principle_components="pc1+pc2+pc3+pc4+pc5+pc6+pc7+pc8+pc9+pc10+pc11+pc12+pc13+pc14+pc15+pc16+pc17+pc18+pc19+pc20"

#Enter where you want your results to be saved
output_wd="~"

#############################################################################################################
#############################################################################################################
#############################################################################################################

software="~/SUGEN"
chrs=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22")
dir_vcf="~"
id_col="sample"
fam_col="gfam"
quant_formulae=("${outcome_variable}=${principle_components}+${covariate_variable}")

dir_res="${output_wd}/res"
if [ ! -d "${dir_res}" ]
then
	mkdir ${dir_res}
fi

file_submit="${output_wd}/tmp.out"
echo "#!bin/bash" > ${file_submit}
module add gcc
for formula in ${quant_formulae[@]}
do
	trait=$(echo ${formula} | tr "=" "\n" | head -n 1)
	
	dir_res_trait="${dir_res}/${trait}"
	if [ ! -d "${dir_res_trait}" ]
	then
		mkdir ${dir_res_trait}
	fi
	echo "cd ${dir_res_trait}" >> ${file_submit}
	
	for chr in ${chrs[@]}
	do	
		file_vcf=${dir_vcf}/chr${chr}RM.dose.vcf.gz
		file_lsflog=${trait}.chr${chr}RM.lsflog
		echo "${cmd} --mem=4g -t 4-00:00:00 -n 2 -o ${file_lsflog} --wrap=\"${software} --pheno ${file_pheno} --id-col ${id_col} --vcf ${file_vcf} --formula ${formula} --unweighted --hetero-variance super_pop --out-prefix ${trait}.chr${chr}RM --dosage\"" >> ${file_submit}
	done
done

for formula in ${binary_formulae[@]}
do
	trait=$(echo ${formula} | tr "=" "\n" | head -n 1)
	
	dir_res_trait="${dir_res}/${trait}"
	if [ ! -d "${dir_res_trait}" ]
	then
		mkdir ${dir_res_trait}
	fi
	echo "cd ${dir_res_trait}" >> ${file_submit}
	
	for chr in ${chrs[@]}
	do
		file_vcf=${dir_vcf}.chr${chr}RM.dose.vcf.gz
		file_lsflog=${trait}.chr${chr}RM.lsflog
		echo "${cmd} --mem=4g -t 4-00:00:00 -n 2 -o ${file_lsflog} --wrap=\"${software} --pheno ${file_pheno} --id-col ${id_col} --vcf ${file_vcf} --formula ${formula} --unweighted --hetero-variance super_pop --out-prefix ${trait}.chr${chr}RM --dosage\"" >> ${file_submit}
	done
done

chmod 700 ${file_submit}
bash ${file_submit}
rm -f ${file_submit}

