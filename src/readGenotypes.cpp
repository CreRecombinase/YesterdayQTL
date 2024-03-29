//FastQTL: Fast and efficient QTL mapper for molecular phenotypes
//Copyright (C) 2015 Olivier DELANEAU, Alfonso BUIL, Emmanouil DERMITZAKIS & Olivier DELANEAU
//
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include "data.h"
#include "tabix.hpp"


void data::readGenotypesVCF(std::string fvcf) {
	std::string buffer;
	std::vector<std::string> str, field;
	int n_includedG = 0;
	int n_excludedG = 0;
	int n_excludedF = 0;
	int n_includedS = 0;
	int n_excludedS = 0;
	int n_missingS = 0;
	int n_parsed = 0;
	std::vector < int > mappingS;

	//Initialise
	LOG.println("\nReading genotype data in [" + fvcf + "] in VCF format");
	if (!futils::isFile(fvcf + ".tbi")) LOG.error("index file missing [" + fvcf + ".tbi]");
	Tabix fd (fvcf);

	//Read samples
	fd.getHeader(buffer);
	if (buffer.size() == 0) LOG.error("No header line detected!");
	sutils::tokenize(buffer, str);
	if (str.size() < 10) LOG.error("Wrong VCF header format for sample ids");
	for (int t = 9 ; t < str.size() ; t ++) {
		if (checkSample(str[t], false)) {
			int idx_sample = -1;
			for (int i = 0 ; i < sample_count && idx_sample < 0 ; i++) if (sample_id[i] == str[t]) idx_sample = i;
			mappingS.push_back(idx_sample);
			if (idx_sample >= 0) n_includedS ++;
			else n_missingS ++;
		} else {
			mappingS.push_back(-1);
			n_excludedS ++;
		}
	}
	if (n_includedS != sample_count) LOG.error("Genotype data does not overlap with phenotype data, check your files!");

	//Read genotypes
	if (!fd.setRegion(regionGenotype.str())) LOG.error("Failed to get region " + regionGenotype.str() + " in [" + fvcf + "]");
	LOG.println("  * region = " + regionGenotype.str());
	while (fd.getNextLine(buffer)) {
        if (buffer.size() == 0) continue;
		sutils::tokenize(buffer, str);
		if (checkGenotype(str[2])) {
			//Check VCF format
			bool gt_field = false;
			int idx_field = -1;
			sutils::tokenize(str[8], field, ":");
			for (int f = 0 ; f < field.size() ; f ++) if (field[f] == "DS") idx_field = f;
			if (idx_field < 0) { for (int f = 0 ; f < field.size() ; f ++) if (field[f] == "GT") idx_field = f; gt_field = true; }
			//Read data is format is correct
			if (idx_field >= 0) {
				genotype_id.push_back(str[2]);
				genotype_chr.push_back(str[0]);
				genotype_pos.push_back(atoi(str[1].c_str()));
				genotype_orig.push_back(std::vector < float > (sample_count, 0.0));
				genotype_curr.push_back(std::vector < float > (sample_count, 0.0));
				for (int t = 9 ; t < str.size() ; t ++) {
					if (mappingS[t-9] >= 0) {
						sutils::tokenize(str[t], field, ":");
						if (str[t] == "." || str[t] == "NN" || str[t] == "NA") genotype_orig.back()[mappingS[t-9]] = -1.0;
						else if (!gt_field) {
							if (field[idx_field][0] == '.') genotype_orig.back()[mappingS[t-9]] = -1.0;
							else {
                                float dosage = atof(field[idx_field].c_str());
                                //if (dosage < 0 || dosage > 2) LOG.error("Dosages must be between 0 and 2, check: " + field[idx_field]);
                                genotype_orig.back()[mappingS[t-9]] = dosage;
							}
						} else {
							if (field[idx_field][0] == '.' || field[idx_field][2] == '.') genotype_orig.back()[mappingS[t-9]] = -1.0;
							else {
								int a0 = atoi(field[idx_field].substr(0, 1).c_str());
								int a1 = atoi(field[idx_field].substr(2, 1).c_str());
                                int dosage = a0 + a1;
                                if (dosage < 0 || dosage > 2) LOG.error("Genotypes must be 00, 01, or 11, check: " + field[idx_field]);
                                genotype_orig.back()[mappingS[t-9]] = dosage;
							}
						}
					}
				}
				n_includedG ++;
			} else n_excludedF ++;
		} else n_excludedG ++;
		n_parsed++;
		if (n_parsed % 100000 == 0) LOG.println("  * " + sutils::int2str(n_parsed) + " lines parsed");
	}

	//Finalise
	genotype_count = n_includedG;
	//LOG.println("  * region = " + regionGenotype.str());
	LOG.println("  * " + sutils::int2str(n_includedS) + " samples included");
	if (n_excludedS > 0) LOG.println("  * " + sutils::int2str(n_excludedS) + " samples excluded");
	if (n_missingS > 0) LOG.println("  * " + sutils::int2str(n_excludedS) + " samples excluded without phenotype data");
	LOG.println("  * " + sutils::int2str(n_includedG) + " sites included");
	if (n_excludedG > 0) LOG.println("  * " + sutils::int2str(n_excludedG) + " sites excluded");
	if (n_excludedF > 0) LOG.println("  * " + sutils::int2str(n_excludedF) + " sites excluded because of missing GT/DS field");
    if (n_includedG <= 0) LOG.error("No genotypes in this region: " + regionPhenotype.str());
}
