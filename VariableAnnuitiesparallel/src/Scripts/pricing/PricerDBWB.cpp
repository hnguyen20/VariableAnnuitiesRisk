
#include "PricerDBWB.h"

#include <algorithm>



void PricerDBWB::project(Policy& policy,  std::map<int, std::vector<std::vector<double>>> &indexScenario, std::vector<double> &fw, int sceInd, int timeInd) {
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

	double dWA = 0.0;

	if (nMonth % 12 == 0  and nMonth >0) {
		policy.gbAmt = std::max(policy.gbAmt, dAV);

	double dWAG = policy.gbAmt * policy.wbWithdrawalRate;
	dWA = std::min(dWAG, policy.gmwbBalance);
	policy.gmwbBalance -= dWA;
	policy.withdrawal += dWA;

	dAV = std::max(0.0, dAV - dWA);
	if(dAV > 1e-4) {
		for(int k=0; k<param.getNumFund(); ++k) {
			policy.fundValue[k] *= dAV / (dAV+dWA);
		}
	}
	else {
		for(int k=0; k<param.getNumFund(); ++k) {
			policy.fundValue[k] = 0.0;
		}
	}
	}

	//update the policy information
	policy.currentDate = Date::add_months(policy.currentDate , 1);

	AV[sceInd][timeInd] = dAV;
	DA[sceInd][timeInd] = std::max(0.0, dWA + policy.gmwbBalance - dAV);
	LA[sceInd][timeInd] = std::max(0.0, dWA - dAV);
	RC[sceInd][timeInd] = dFee;


	// at maturity or the maturity date is after the last scenario date
	if (T == 0 or (T > 0 and Param::NUMSTEP -1 == timeInd)) {
		LA[sceInd][timeInd] = std::max(0.0, dWA + policy.gmwbBalance - dAV);
	}

}


