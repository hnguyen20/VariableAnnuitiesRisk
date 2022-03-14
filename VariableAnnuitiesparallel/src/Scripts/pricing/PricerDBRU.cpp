
#include "PricerDBRU.h"

#include <algorithm>



void PricerDBRU::project(Policy& policy,  std::map<int, std::vector<std::vector<double>>> &indexScenario, std::vector<double> &fw, int sceInd, int timeInd) {
	//time to maturity
	int T = Date::month_between(policy.matDate, policy.currentDate);
	if (T < 0) {
		return;
	}


	int nMonth = Date::month_between(policy.currentDate, policy.issueDate);
	double dAV = 0.0, dFee = 0.0, dPartialAV = 0.0;

	for (int k = 0; k < param.getNumFund(); k++){
		double dPartialAV = policy.fundValue[k] *
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

	//update the policy information
	policy.currentDate = Date::add_months(policy.currentDate , 1);
	if (nMonth % 12 == 0  and nMonth >0) {
		policy.gbAmt *= 1 + policy.rollUpRate;
	}


	AV[sceInd][timeInd] = dAV;
	DA[sceInd][timeInd] = std::max(0.0, policy.gbAmt - dAV);
	DA[sceInd][timeInd] = 0.0;
	RC[sceInd][timeInd] = dFee;

}


