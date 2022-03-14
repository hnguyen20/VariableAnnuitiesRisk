
#include <iostream>
#include <ctime>

using namespace std;
#include <stdio.h>
#include <time.h>
#include "Date.h"
#include <boost/date_time/gregorian/gregorian.hpp>
#include<string>
#include <sstream>
#include <iomanip>



Date::Date() {
	// TODO Auto-generated constructor stub

}

Date::~Date() {
	// TODO Auto-generated destructor stub
}

std::tm Date::stringtodate(std::string date_string){
    /*
    Convert a string with format dd/mm/YYYY
    */
	std::string data;
	std::tm tmDate;
	std::istringstream ss(date_string);
	std::getline(ss, data, '/');
	tmDate.tm_mday = std::stoi(data);
	std::getline(ss, data, '/');
	tmDate.tm_mon = std::stoi(data);
	std::getline(ss, data, '/');
	tmDate.tm_year = std::stoi(data);
    return tmDate;
}

std::tm Date::stringtodate(const char* date_string){
    /*
    Convert a string with format dd/mm/YYYY
    */
	std::tm tmDate;
	sscanf(date_string,"%2d/%2d/%4d",&tmDate.tm_mday,&tmDate.tm_mon,&tmDate.tm_year);
    return tmDate;
}

int Date::month_between(std::tm dateto, std::tm datefrom){
	int num_months = (dateto.tm_year-datefrom.tm_year)*12 + dateto.tm_mon - datefrom.tm_mon;
	return num_months;
}

double Date::year_between(std::tm dateto, std::tm datefrom){
	/*
	std::time_t to = std::mktime(&dateto);
	std::time_t from = std::mktime(&datefrom);
	double days_diff;
	if ( to != (std::time_t)(-1) && from != (std::time_t)(-1) ){
		days_diff = std::difftime(to, from) / (60 * 60 * 24);
	}
	return (double) days_diff/365.0;
	*/
	return (julianDate(dateto) - julianDate(datefrom))/365.0;
}

std::tm Date::add_months(std::tm date, int months){
	boost::gregorian::date gregDate = boost::gregorian::date_from_tm(date);
	boost::gregorian::month_iterator m_itr(gregDate);
	for (int i = 0; i< months; i++){
		++m_itr;
	}
	return boost::gregorian::to_tm(*m_itr);
}

void Date::printDate(std::tm date){
	std::cout << date.tm_mday << "/" << date.tm_mon << "/" << date.tm_year <<std::endl;
}


double Date::julianDate(std::tm date) {
	int y, m, d;
	d = date.tm_mday;
	m = date.tm_mon;
	y = date.tm_year;
	assert(y>=1582);
	long Y = y;
	long M = m;
	if (m <3) {
		M+=12;
		Y-=1;
	}
	long A = (long) Y/100;
	long B = (long) A/4;
	long C = 2-A+B;
	long E = (long) (365.25*(Y+4716));
	long F = (long) (30.6001*(M+1));
	double JD = (double) (C+d+E+F-1524.5);
	return JD;
}


