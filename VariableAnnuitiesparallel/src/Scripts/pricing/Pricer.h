#ifndef SCRIPTS_PRICING_PRICER_H_
#define SCRIPTS_PRICING_PRICER_H_

#include "../../Data/Param.h"
#include "../../Scripts/utils/Date.h"
#include "../policy/Policy.h"
#include <time.h>
#include <iostream>
#include <sstream>
#include <math.h>


struct PolicyResult {
    double riskCharge = 0.0, gmdb = 0.0, gmlb = 0.0, guaranteedbenefit = 0.0, fmv = 0.0;
    double av[Param::NUMINDEX] = {0.0};

};


struct Shock {
    /*
    Example: shockname = base:2_D, indexshockk = [0,-0.01,0,0,0] which means
    index 2 goes down by 10 basic points
    */
	std::string shockname;
	std::vector<double> indexshock;
};

class Pricer {
protected:
    //Account value, death benefit, living benefit, risk charge, size  numscenario x numstep
	std::vector<std::vector<double>> AV, DA, LA, RC;
	//Discount factor, mortality rate, survivor rate, size numstep+1
	std::vector<double> df, q, s;
	std::map<std::string, std::map<int, std::vector<std::vector<double>>>>*  irIndexScenario;
	std::map<std::string, std::vector<double>>* irFW;
	//Time step
	double dt;
	Param& param = Param::instance();

public:
	Pricer(std::map<std::string, std::map<int, std::vector<std::vector<double>>>>*, std::map<std::string, std::vector<double>>*, Param&);
	virtual ~Pricer(){};
	PolicyResult evaluate(Policy, Shock) ;
	PolicyResult evaluateScenario(Policy, int, Shock);
	std::vector<PolicyResult> evaluateScenario(Policy, std::map<int, std::vector<std::vector<double>>>&);
//	std::vector<PolicyResult> evaluateScenarioIndp(Policy, std::map<int, std::vector<std::vector<double>>>& );
	virtual void project(Policy&,  std::map<int, std::vector<std::vector<double>>> &, std::vector<double>&, int , int ) = 0;
//	virtual void projectIndp(Policy&, std::vector<double>,  std::map<int, std::vector<std::vector<double>>> &, std::vector<double>&, int , int ) = 0;

	double getfundScenario(int,   std::map<int, std::vector<std::vector<double>>> &, int, int)  ;
	double getAnnuityFactor(Policy, int, std::vector<double> &);
	double getAnnuityFactor_r(Policy, double);
};

#endif /* SCRIPTS_PRICING_PRICER_H_ */
