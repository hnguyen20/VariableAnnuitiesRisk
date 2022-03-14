#ifndef SCRIPTS_PRICING_PRICERMAIN_H_
#define SCRIPTS_PRICING_PRICERMAIN_H_
#include<string>
#include "Pricer.h"


class Pricermain {
	std::map<std::string, std::map<int, std::vector<std::vector<double>>>> irIndexScenario;
	std::map<std::string, std::vector<double>> irFW;
	std::vector<Policy> inforce;
	Param& param = Param::instance();
	typedef std::map<std::string, Pricer*> map_type;


public:
	Pricermain(std::string,std::string);
	virtual ~Pricermain(){};
	void loadInforce(std::string);
	void loadScenario(std::string);
	void valuation(std::string);
	//void valuationScenario(int, std::string);
	void valuationScenario(std::string, std::string, std::string);
	void valuationScenarioCorr(std::string, std::string, std::string);
	void valuationScenario(std::string, std::string);
	void valuationScenario(std::string, int, std::string); //Sandom sampling scenarios for selected policies
	void valuationScenario(int, std::string); //Random sampling scenarios for all policies
	template<typename T> Pricer* createInstance () {return new T(&irIndexScenario, &irFW, param);}
	int test(std::map<std::string, std::map<int, std::vector<std::vector<double>>>>& irIndexScen,
			std::map<std::string, std::vector<double>>& fwRates){
		std::map<std::string, std::map<int, std::vector<std::vector<double>>>>* indexscen;
		indexscen= &irIndexScen;
		return 1;}
	void printInforce(std::string, std::string);
	std::map<std::string,std::map<std::string,double>> loadFMVfile(std::string);
	Pricer* createPricer(std::string prodType);
};

#endif /* SCRIPTS_PRICING_PRICERMAIN_H_ */
