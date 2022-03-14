

#ifndef SCRIPTS_UTILS_DATE_H_
#define SCRIPTS_UTILS_DATE_H_

#include <time.h>
#include <ctime>
#include<string>

class Date {
	public:
		Date();
		virtual ~Date();
		static std::tm stringtodate(const char*);
		static std::tm stringtodate(std::string date_string);
		static int month_between(std::tm, std::tm);
		static double year_between(std::tm, std::tm);
		static std::tm add_months(std::tm, int);
		static void printDate(std::tm);
		static double julianDate(std::tm);
};

#endif /* SCRIPTS_UTILS_DATE_H_ */
