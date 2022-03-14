
#ifndef SCRIPTS_UTILS_MORTALITY_H_
#define SCRIPTS_UTILS_MORTALITY_H_
#include <string>
#include <map>

class Mortality {
	std::map<int, double> morttable;
	public:
		Mortality();
		virtual ~Mortality();
		void Init(std::string);
		double p(double, double);
		double q(double, double);


};

#endif /* SCRIPTS_UTILS_MORTALITY_H_ */
