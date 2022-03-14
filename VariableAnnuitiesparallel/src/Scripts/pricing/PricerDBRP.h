

#ifndef SCRIPTS_PRICING_PRICERDBRP_H_
#define SCRIPTS_PRICING_PRICERDBRP_H_
#include "Pricer.h"

class PricerDBRP: public Pricer {
public:
	PricerDBRP(std::map<std::string, std::map<int, std::vector<std::vector<double>>>>* irIndexScen,
				std::map<std::string, std::vector<double>>* fwRates, Param& param): Pricer(irIndexScen,fwRates,param){}
	void project(Policy& policy, std::map<int, std::vector<std::vector<double>>> &, std::vector<double> &, int scenario_i, int timestep_j);
};

#endif /* SCRIPTS_PRICING_PRICERDBRP_H_ */
