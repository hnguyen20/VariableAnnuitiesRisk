
#ifndef SCRIPTS_POLICY_POLICY_H_
#define SCRIPTS_POLICY_POLICY_H_
#include <string>
#include <map>
#include <vector>
#include <iostream>
#include <sstream>
#include <math.h>
#include "../utils/Date.h"
#include "../../Data/Param.h"

class Policy {
public:
	std::tm issueDate, matDate, birthDate, currentDate;
	double baseFee, riderFee, rollUpRate;
	double gbAmt, gmwbBalance, wbWithdrawalRate,withdrawal,survivorShip;
	std::vector<double> fundValue, fundFee;
	char gender;
	std::string recordID, productType;
	std::vector<std::string> policyFields{"recordID", "FundValue1", "FundValue2", "FundValue3",
			"FundValue4", "FundValue5", "FundValue6", "FundValue7", "FundValue8",
			"FundValue9", " FundValue10", "FundFee1", "FundFee2", "FundFee3",
			"FundFee4", "FundFee5", "FundFee6", "FundFee7", "FundFee8", "FundFee9",
			" FundFee10", "baseFee", "riderFee", "rollUpRate", "gbAmt", "gmwbBalance",
			"wbWithdrawalRate", "withdrawal", "age", "timeTMatur", "timeIF",
			"productType", "gender"};
	Param& param = Param::instance();
public:
	Policy();
	virtual ~Policy();
	void printPolicy(std::map<std::string,std::map<std::string,double>> &, std::string);
	void printPolicyHeader(std::string);
};

#endif /* SCRIPTS_POLICY_POLICY_H_ */


