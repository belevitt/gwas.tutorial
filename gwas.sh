#!/bin/bash
cmd="sbatch --time=3-0:00:00 --mem=80g"

#############################################################################################################
#############################################################################################################
#############################################################################################################

#Only modify stuff up here, please

#Enter the path and name for your phenotype file
file_pheno="/ifs/sec/cpc/addhealth/users/belevitt/datamanagement/toydataset/testrun/phenofile.050619"

#Enter the name of your outcome variable
outcome_variable="outcome1"

#Enter the name of your covariates
covariate_variable="pop"
principle_components="PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20"

#Enter where you want your results to be saved
output_wd="/ifs/sec/cpc/addhealth/users/belevitt/datamanagement/toydataset/testrun"

#############################################################################################################
#############################################################################################################
#############################################################################################################

software="/ifs/sec/cpc/addhealth/apps/bin/SUGEN"
chrs=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22")
dir_vcf="/ifs/sec/cpc/addhealth/users/belevitt/datamanagement/toydataset/testrun"
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
		file_vcf=${dir_vcf}/chr${chr}.vcf.gz
		file_lsflog=${trait}.chr${chr}.lsflog
		echo "${cmd} --mem=4g -t 4-00:00:00 -n 2 -o ${file_lsflog} --wrap=\"${software} --pheno ${file_pheno} --id-col ${id_col} --vcf ${file_vcf} --formula ${formula} --unweighted --hetero-variance super_pop --out-prefix ${trait}.chr${chr}\"" >> ${file_submit}
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
		file_vcf=${dir_vcf}.chr${chr}.vcf.gz
		file_lsflog=${trait}.chr${chr}.lsflog
		echo "${cmd} --mem=4g -t 4-00:00:00 -n 2 -o ${file_lsflog} --wrap=\"${software} --pheno ${file_pheno} --id-col ${id_col} --vcf ${file_vcf} --formula ${formula} --unweighted --hetero-variance super_pop --out-prefix ${trait}.chr${chr}\"" >> ${file_submit}
	done
done

chmod 700 ${file_submit}
bash ${file_submit}
rm -f ${file_submit}

