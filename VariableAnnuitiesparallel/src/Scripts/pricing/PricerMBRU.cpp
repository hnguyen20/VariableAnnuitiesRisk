
#include "PricerMBRU.h"

#include <algorithm>



void PricerMBRU::project(Policy& policy,  std::map<int, std::vector<std::vector<double>>> &indexScenario, std::vector<double> &fw, int sceInd, int timeInd) {
	//time to maturity

	double T = Date::month_between(policy.matDate, policy.currentDate);
	if (T < 0) {
		return;
	}


	int nMonth = Date::month_between(policy.currentDate, policy.issueDate);
	double dAV = 0.0, dFee = 0.0, dPartialAV = 0.0;

	for (int k = 0; k < param.getNumFund(); k++){
		dPartialAV = policy.fundValue[k] *
					getfundScenario(k, indexScenario, sceInd, timeInd)
					* (1 - policy.fundFee[k] * dt);
		double dPartialFee = 0.0, dBaseFee = 0.0;

		if (nMonth % 12 == 0  and nMonth >0) {
			dPartialFee = dPartialAV * policy.riderFee;
			dBaseFee = dPartialAV * policy.baseFee;
		}

		policy.fundValue[k] = dPartialAV - dPartialFee - dBaseFee;

		dAV = dAV + policy.fundValue[k];
		dFee = dFee + dPartialFee;
	}

	if (nMonth % 12 == 0  and nMonth >0) {
		policy.gbAmt *= 1 + policy.rollUpRate;
	}



	//update the policy information
	policy.currentDate = Date::add_months(policy.currentDate , 1);

	AV[sceInd][timeInd] = dAV;
	DA[sceInd][timeInd] = 0.0;
	LA[sceInd][timeInd] = 0.0;
	RC[sceInd][timeInd] = dFee;


	// at maturity or the maturity date is after the last scenario date
	if (T == 0 or (T > 0 and Param::NUMSTEP -1 == timeInd)) {
		LA[sceInd][timeInd] = std::max(0.0, policy.gbAmt - dAV);
	}

}


