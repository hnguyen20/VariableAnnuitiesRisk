/*
 * Mortality.cpp
 *
 *  Created on: 20 Jan 2020
 *      Author: hangn
 */
#include <iostream>
#include "Mortality.h"
#include <fstream>
#include <sstream>
#include <stdio.h>
#include <math.h>

Mortality::Mortality() {
}

Mortality::~Mortality() {
	// TODO Auto-generated destructor stub
}


void Mortality::Init(std::string mortfile) {
		std::ifstream infile(mortfile);
		std::string line, data;

		while (std::getline(infile, line))
		{
			if (*line.rbegin() == '\r')
			{
				line.erase(line.length() - 1);
			}
		    std::istringstream iss(line);

		    int age;
		    double mort;

		    std::getline(iss,data, ',');
		    age = std::stoi(data);
		    std::getline(iss,data);
		    mort = std::stod(data);

		    morttable[age] = mort;
		}
}

double Mortality::p(double age, double t){
	int x = (int) floor(age);
	int x_plus_t = (int) floor(age + t);
	double pxt = 1.0;
	for (int i = x;  i < x_plus_t ; i++){
		pxt = pxt * (1 - morttable[i]);
	}
	return pxt * (1 - (age + t - x_plus_t) * morttable[x_plus_t])
			/(1-(age-x)*morttable[x]);
}

double Mortality::q(double age, double t){
	return 1- p(age, t);
}


