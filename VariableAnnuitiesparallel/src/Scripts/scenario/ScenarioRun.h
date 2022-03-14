

#ifndef SCRIPTS_SCENARIO_SCENARIORUN_H_
#define SCRIPTS_SCENARIO_SCENARIORUN_H_

#include "../pricing/Pricermain.h"

class ScenarioRun {
public:
	ScenarioRun();
	virtual ~ScenarioRun();
	void printResult(std::string, std::string, std::string);
};

#endif /* SCRIPTS_SCENARIO_SCENARIORUN_H_ */
