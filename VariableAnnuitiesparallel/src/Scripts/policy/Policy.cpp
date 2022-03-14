#include "Policy.h"
#include "../../Data/Param.h"
#include <fstream>
#include "../utils/Date.h"

Policy::Policy() {
	//The size of policyField was 33. We add more fields for fair market values in different shock cases.
	for (auto const & shockname : param.getShockMap()){
		policyFields.push_back(shockname.first);
	}
}


void Policy::printPolicy(std::map<std::string,std::map<std::string,double>>& fmvMap, std::string outputfile){
	/*
	 * Print in the order of continuous, ordinal and nominal variables
	fundValue, fundFee, baseFee, riderFee, rollUpRate, gbAmt, gmwbBalance, wbWithdrawalRate,
	withdrawal, age, timeTMatur (time to maturity), timeIF (time in force from issued date to currrent date),
	product type, gender
	 */
	Param& param = Param::instance();
	std::ofstream outfile;
	outfile.open(outputfile, std::ios_base::app);
	outfile << recordID << ',';
	for (int k = 0; k < param.getNumFund(); k++){
		outfile << fundValue[k] << ',';
	}
	for (int k = 0; k < param.getNumFund(); k++){
		outfile << fundFee[k] << ',';
	}
	outfile << baseFee << ',' << riderFee << ',' << rollUpRate << ','
			<< gbAmt << ',' << gmwbBalance << ',' << wbWithdrawalRate << ','
			<< withdrawal << ',';

	double age = Date::year_between(currentDate, birthDate);

	double timeTMatur = Date::month_between(matDate, currentDate);

	int timeIF = Date::month_between(currentDate, issueDate);
	outfile << age << ',' << timeTMatur << ',' << timeIF << ','
			<< productType << ',' << gender ;

	//Print fair market values
	for (int i = 33; i < policyFields.size(); i++){
		outfile << ',' << fmvMap[recordID][policyFields[i]];
	}
	outfile << std::endl;
	outfile.close();

}

void Policy::printPolicyHeader(std::string outputfile){
	std::ofstream outfile;
	outfile.open(outputfile);
	outfile << "recordID";
	for (int i = 1; i < policyFields.size(); i++){
		outfile << ',' << policyFields[i];
	}
	outfile << std::endl;
	outfile.close();
}

Policy::~Policy() {
	// TODO Auto-generated destructor stub

}

