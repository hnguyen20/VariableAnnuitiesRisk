

#ifndef SCRIPTS_PRICING_PRICERDBMB_H_
#define SCRIPTS_PRICING_PRICERDBMB_H_
#include "Pricer.h"

class PricerDBMB: public Pricer {
public:
	PricerDBMB(std::map<std::string, std::map<int, std::vector<std::vector<double>>>>* irIndexScen,
				std::map<std::string, std::vector<double>>* fwRates, Param& param): Pricer(irIndexScen,fwRates,param){}
	void project(Policy& policy, std::map<int, std::vector<std::vector<double>>> &, std::vector<double> &, int scenario_i, int timestep_j);
};

#endif /* SCRIPTS_PRICING_PRICERDBMB_H_ */
