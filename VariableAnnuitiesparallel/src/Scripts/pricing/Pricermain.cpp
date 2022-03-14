
#include "Pricermain.h"
#include "../utils/Random.h"
#include <cmath>
#include <fstream>
#include <iostream>
#include <sstream>
#include <algorithm>
//#include <experimental/algorithm>
#include <iterator>
#include <random>
#include "../policy/Policy.h"
#include "PricerABRP.h"
#include "PricerABRU.h"
#include "PricerABSU.h"
#include "PricerDBAB.h"
#include "PricerDBIB.h"
#include "PricerDBMB.h"
#include "PricerDBRP.h"
#include "PricerDBRU.h"
#include "PricerDBSU.h"
#include "PricerDBWB.h"
#include "PricerIBRP.h"
#include "PricerIBRU.h"
#include "PricerIBSU.h"
#include "PricerMBRP.h"
#include "PricerMBRU.h"
#include "PricerMBSU.h"
#include "PricerWBRP.h"
#include "PricerWBRU.h"
#include "PricerWBSU.h"

Pricermain::Pricermain(std::string inforcefile, std::string scen_folder) {
	loadInforce(inforcefile);
	loadScenario(scen_folder);
	std::cout << "Finished loading." << std::endl;

	std::cout << "Created pricer." << std::endl;
}

Pricer* Pricermain::createPricer(std::string prodType){
	if (prodType == "ABRP") return createInstance<PricerABRP>();
	else if (prodType == "ABRU") return createInstance<PricerABRU>();
	else if (prodType == "ABSU") return createInstance<PricerABSU>();
	else if (prodType == "DBAB") return createInstance<PricerDBAB>();
	else if (prodType == "DBIB") return createInstance<PricerDBIB>();
	else if (prodType == "DBMB") return createInstance<PricerDBMB>();
	else if (prodType == "DBRP") return createInstance<PricerDBRP>();
	else if (prodType == "DBRU") return createInstance<PricerDBRU>();
	else if (prodType == "DBSU") return createInstance<PricerDBSU>();
	else if (prodType == "DBWB") return createInstance<PricerDBWB>();
	else if (prodType == "IBRP") return createInstance<PricerIBRP>();
	else if (prodType == "IBRU") return createInstance<PricerIBRU>();
	else if (prodType == "IBSU") return createInstance<PricerIBSU>();
	else if (prodType == "MBRP") return createInstance<PricerMBRP>();
	else if (prodType == "MBRU") return createInstance<PricerMBRU>();
	else if (prodType == "MBSU") return createInstance<PricerMBSU>();
	else if (prodType == "WBRP") return createInstance<PricerWBRP>();
	else if (prodType == "WBRU") return createInstance<PricerWBRU>();
	else if (prodType == "WBSU") return createInstance<PricerWBSU>();

}

void Pricermain::loadInforce(std::string inforcefile){
	std::cout << "Load inforce file" << std::endl;
	std::ifstream infile1(inforcefile);
	std::string line, data;
	std::vector<std::string> header;
	//Get header line
	std::getline(infile1, line);
	if (*line.rbegin() == '\r')
	    {
	        line.erase(line.length() - 1);
	    }
	std::istringstream iss(line);

	int i = 0;
    while (std::getline(iss,data, ',')) {

    	header.push_back(data);
    	i++;

    }
    iss.clear();
	while (std::getline(infile1, line)){
    	if (*line.rbegin() == '\r')
    	    {
    	        line.erase(line.length() - 1);
    	    }
		std::map<std::string, std::string> rowdata;
	    std::istringstream iss1(line);

	    int j = 0;
	    while (std::getline(iss1,data, ',') ) {

	    	rowdata[header[j]] = data;
	    	j++;
	    }
	    iss1.clear();
	    Policy p;
	    p.issueDate = Date::stringtodate(rowdata["issueDate"]);
	    p.matDate = Date::stringtodate(rowdata["matDate"]);
	    p.birthDate = Date::stringtodate(rowdata["birthDate"]);
	    p.currentDate = Date::stringtodate(rowdata["currentDate"]);


	    p.baseFee = std::stod(rowdata["baseFee"]);
	    p.riderFee = std::stod(rowdata["riderFee"]);
	    p.rollUpRate = std::stod(rowdata["rollUpRate"]);
	    p.gbAmt = std::stod(rowdata["gbAmt"]);
	    p.gmwbBalance = std::stod(rowdata["gmwbBalance"]);
	    p.wbWithdrawalRate = std::stod(rowdata["wbWithdrawalRate"]);
	    p.withdrawal = std::stod(rowdata["withdrawal"]);
	    p.survivorShip = std::stod(rowdata["survivorShip"]);

	    for (int k = 0; k < param.getNumFund(); k++){
	    	std::string fundValuek = "FundValue" + std::to_string(k+1);
	    	std::string fundFeek = "FundFee" + std::to_string(k+1);
	    	p.fundValue.push_back(std::stod(rowdata[fundValuek]));
	    	p.fundFee.push_back(std::stod(rowdata[fundFeek]));
	    }

	    p.gender = rowdata["gender"][0];
	    p.recordID = rowdata["recordID"];
		p.productType = rowdata["productType"];

	    inforce.push_back(p);
	}

	infile1.close();


}

void Pricermain::loadScenario(std::string scen_folder) {
	std::cout << "Load scenario file" << std::endl;
	for (auto const & ir_shock : param.getIRShockList()){
		//Load index return
		std::map<int, std::vector<std::vector<double>>>indexScenario;

		int  i = 0;
		for (auto const index : param.getIndexMap()){
			std::vector<std::vector<double>> scenario;
			std::string indexfile = index + ".csv";
			std::string scenario_file = scen_folder+ir_shock + "/" + indexfile;
			std::ifstream infile(scenario_file);
			std::string line, data;

			while (std::getline(infile, line))
			{
				if (*line.rbegin() == '\r')
				{
					line.erase(line.length() - 1);
				}
			    std::istringstream iss(line);
			    std::getline(iss,data, ','); //Skip the first column
			    std::vector<double> scenarioline;
			    while (std::getline(iss,data, ',')) {
			    	scenarioline.push_back(stod(data));
			    }
			    iss.clear();
			    scenario.push_back(scenarioline);
			}
			infile.close();
			indexScenario[i] = scenario;
			i++;
		}

		//Load forward rate
		std::string fw_file = scen_folder+'/'+ir_shock+"/ForwardCurve.csv";
		std::ifstream infile(fw_file);
		std::string line, data;
		std::getline(infile, line);
		std::getline(infile, line); //Skip the first two lines
		std::vector<double> irRates;
		while (std::getline(infile, line))
		{
			if (*line.rbegin() == '\r')
			{
				line.erase(line.length() - 1);
			}
			irRates.push_back(stod(line));
		}
		infile.close();


		irIndexScenario[ir_shock] = indexScenario;
		irFW[ir_shock]= irRates;
	}
}

/*
 * Valuation of all policies in inforce file with scenarios specified by irIndexScenario, an instance of Pricermain
 */
void Pricermain::valuation(std::string outputfile){

    std::ofstream outfile;
    outfile.open (outputfile);
    outfile << "recordID";
    std::vector<std::string> shocknames;

    int i = 0;
    for (auto const & shockname : param.getShockMap()){
    	outfile << ',';
    	outfile << shockname.first ;
    	shocknames.push_back(shockname.first);
    	i++;
    }
    outfile << std::endl;


    int numPol = 0;
    for (auto  const & policy : inforce){
        Pricer*  riderPricer = createPricer(policy.productType);
        outfile << policy.recordID;
        for (int j = 0; j < shocknames.size(); j++){
        	Shock shocktype;
        	shocktype.shockname = shocknames[j];
        	shocktype.indexshock = param.getShockMap()[shocknames[j]];
            //Valuation
            std::cout << "Shock: " << shocktype.shockname << ", valuing record "
            		<< policy.recordID << std::endl;

            PolicyResult res = riderPricer->evaluate(policy, shocktype);

            outfile << ',';
            outfile  << res.fmv;
            std::cout << "Shock: " << shocktype.shockname << ", Done Valuing"
            		<< policy.recordID << std::endl;
        }
        delete riderPricer;
        numPol++;
        outfile << std::endl;
    }
    outfile.close();
    std::cout << "Done valuation." << std::endl;
    std::cout << "Number of policies: " << numPol << std::endl;
}
/*
void Pricermain::valuationScenario(int numRepScenario, std::string outputfolder){

    std::ofstream outfile;
    int numPol = 0;
    for (auto  const & policy : inforce){
		std::cout << "valuing record "
				<< policy.recordID << std::endl;
    	std::string outputfile = outputfolder + policy.recordID + ".csv";
        outfile.open (outputfile);
        outfile << "recordID";
        std::vector<std::string> shocknames;

        int i = 0;
        for (auto const & shockname : param.getShockMap()){
        	outfile << ',';
        	outfile << shockname.first ;
        	shocknames.push_back(shockname.first);
        	i++;
        }
        outfile << std::endl;

        Pricer*  riderPricer = createPricer(policy.productType);

        for (int sceInd = 0; sceInd < numRepScenario; sceInd++){
        	outfile << policy.recordID;
			for (int j = 0; j < shocknames.size(); j++){
				Shock shocktype;
				shocktype.shockname = shocknames[j];
				shocktype.indexshock = param.getShockMap()[shocknames[j]];
				//Valuation

				PolicyResult res = riderPricer->evaluateScenario(policy, sceInd, shocktype);
				delete riderPricer;
				outfile << ',';
				outfile  << res.fmv;


			}
			outfile << std::endl;
        }
        outfile.close();
		std::cout << "Done Valuing" << policy.recordID << std::endl;

        numPol++;
    }
    std::cout << "Done valuation." << std::endl;
    std::cout << "Number of policies: " << numPol << std::endl;
}
*/
void Pricermain::printInforce(std::string fmvfile_full, std::string outputfile){
	Policy pol;
	pol.printPolicyHeader(outputfile);
	std::map<std::string,std::map<std::string,double>> fmvMap = loadFMVfile(fmvfile_full);
	std::cout << "Printing record." << std::endl;
	for (auto & policy : inforce){
		std::cout << "Record ID" << policy.recordID << std::endl;
		policy.printPolicy(fmvMap, outputfile);
	}
}


std::map<std::string,std::map<std::string,double>> Pricermain::loadFMVfile(std::string fmvfile_full){
	std::map<std::string,std::map<std::string,double>> fmvMap;
	std::cout << "Load FMV file" << std::endl;
	std::ifstream infile(fmvfile_full);
	std::string line, data;
	std::vector<std::string> header;
	//Get header line
	std::getline(infile, line);
	if (*line.rbegin() == '\r')
	    {
	        line.erase(line.length() - 1);
	    }
	std::istringstream iss(line);

	int i = 0;
    while (std::getline(iss,data, ',')) {

    	header.push_back(data);
    	i++;

    }
    iss.clear();
	while (std::getline(infile, line)){
    	if (*line.rbegin() == '\r')
    	    {
    	        line.erase(line.length() - 1);
    	    }
		std::map<std::string, std::string> rowdata;
	    std::istringstream iss(line);

	    std::string recordID;
	    std::getline(iss,recordID, ',');
	    int j = 1;

	    while (std::getline(iss,data, ',') ) {

	    	fmvMap[recordID][header[j]] = stod(data);
	    	j++;
	    }

	    iss.clear();

	}
	infile.close();
	return fmvMap;


}

/*
 * Input: File containing Representative policies, Folder containing files of scenarios of index
 * Output: Run scenarios on representative policies, print to output file
 */
void Pricermain::valuationScenario(std::string repPolFile, std::string scenfolder, std::string outputfile){
	std::map<int, std::vector<std::vector<double>>> indexScenario;
	int  i = 0;
	for (auto const index : param.getIndexMap()){
		std::vector<std::vector<double>> scenario;
		std::string indexfile = index + ".csv";
		std::string scenario_file = scenfolder+ "/" + indexfile;
		std::ifstream infile(scenario_file);
		std::string line, data;

		while (std::getline(infile, line))
		{
			if (*line.rbegin() == '\r')
			{
				line.erase(line.length() - 1);
			}
		    std::istringstream iss(line);
		    std::vector<double> scenarioline;
		    while (std::getline(iss,data, ',')) {
		    	scenarioline.push_back(stod(data));
		    }
		    iss.clear();
		    scenario.push_back(scenarioline);
		}
		infile.close();
		indexScenario[i] = scenario;
		i++;
	}
	std::vector<std::string> repPols;
	std::ifstream infile(repPolFile);
	std::string line, data;

	while (std::getline(infile, line))
	{
		if (*line.rbegin() == '\r')
		{
			line.erase(line.length() - 1);
		}
	    std::istringstream iss(line);
	    while (std::getline(iss,data, ',')) {
	    	repPols.push_back(data);
	    }
	    iss.clear();
	}
	infile.close();

    std::ofstream outfile;
    outfile.open (outputfile);
    outfile << "recordID";
    for (int i = 0; i < indexScenario[0].size(); i++){
    	outfile << ',' << "RepScenario"+ std::to_string(i+1);
    }
    outfile << std::endl;


    int numPol = 0;
    for (auto const p : repPols){
		for (auto  const & policy : inforce){
			if (policy.recordID != p){
				continue;
			}
			std::cout << "valuing record "
					<< policy.recordID << std::endl;
			outfile << policy.recordID;

			Pricer*  riderPricer = createPricer(policy.productType);

			std::vector<PolicyResult> resScen = riderPricer->evaluateScenario(policy, indexScenario);
			delete riderPricer;
			for (int i = 0; i < indexScenario[0].size(); i++){
				outfile << ',' << resScen[i].fmv;
			}
			outfile << std::endl;
		}
		numPol++;
    }
	outfile.close();


    std::cout << "Done valuation." << std::endl;
    std::cout << "Number of policies: " << numPol << std::endl;
}


/*
 * Input: file containing representative policies (repPolFile), number of representative scenario
 * Output: generate representative scenarios by random sampling, run the scenarios
 * for representative policies and print result to outputfile
 */
void Pricermain::valuationScenario(std::string repPolFile, int numRepScen, std::string outputfile){

	std::map<int, std::vector<std::vector<double>>> indexScenario;

	std::vector<int> population(Param::NUMSCENARIO) ; // vector with NUMSCENARIO = 1000 ints.
	std::iota (std::begin(population), std::end(population), 0); // Fill with 0, 1, ..., 999
	std::vector<int> sample;
	if (numRepScen < Param::NUMSCENARIO){
	/*	std::experimental::sample(population.begin(), population.end(),
						std::back_inserter(sample),
						numRepScen,
						std::mt19937{std::random_device{}()}); //100  randomly chosen values from population vector*/
		std::mt19937 mt(std::random_device{}());
		std::unordered_set<int> sampleset=Random::pickSet(Param::NUMSCENARIO, numRepScen, mt);
		sample.insert(sample.end(), sampleset.begin(), sampleset.end());
	}
    if (numRepScen == Param::NUMSCENARIO){
    	for (int i = 0; i < numRepScen; i++)
    	sample.push_back(i);
    }
	for (int i = 0; i < Param::NUMINDEX; i++){
		std::vector<std::vector<double>> scenarios;
		for (int j = 0; j < numRepScen; j++){
			scenarios.push_back(irIndexScenario["base"][i][sample[j]]);
		}
		indexScenario[i] = scenarios;
	}


	std::vector<std::string> repPols;
	std::ifstream infile(repPolFile);
	std::string line, data;

	while (std::getline(infile, line))
	{
		if (*line.rbegin() == '\r')
		{
			line.erase(line.length() - 1);
		}
	    std::istringstream iss(line);
	    while (std::getline(iss,data, ',')) {
	    	repPols.push_back(data);
	    }
	    iss.clear();
	}
	infile.close();

    std::ofstream outfile;
    outfile.open (outputfile);
    outfile << "recordID";
    for (int i = 0; i < indexScenario[0].size(); i++){
    	outfile << ',' << "Scenario"+ std::to_string(i+1);
    }
    outfile << std::endl;


    int numPol = 0;
    std::vector<PolicyResult> resScen;

#pragma omp parallel for num_threads(2) private(resScen)
    for (auto const p : repPols){

    	//int tid=omp_get_thread_num();
    	std::cout << "valuing record "
    						<< p << std::endl;
		for (const auto &policy : inforce){
		if (policy.recordID != p){
				continue;
			}
		//int a = test(irIndexScenario,irFW);
			Pricer*  riderPricer = createPricer(policy.productType);
			resScen = riderPricer->evaluateScenario(policy, indexScenario);
			delete riderPricer;
		#pragma omp critical
			{
			outfile << policy.recordID;
			for (int i = 0; i < indexScenario[0].size(); i++){
				outfile << ',' << resScen[i].fmv;
			}

			outfile << std::endl;
			numPol++;
			}
			break;
		}

    }


	outfile.close();


    std::cout << "Done valuation." << std::endl;
    std::cout << "Number of policies: " << numPol << std::endl;
}

/*
 * Input: number of representative scenario
 * Output: generate representative scenarios by random sampling, run the scenarios
 * for all policies and print result to outputfile
 */
void Pricermain::valuationScenario(int numRepScen, std::string outputfile){
	std::map<int, std::vector<std::vector<double>>> indexScenario;

	std::vector<int> population(Param::NUMSCENARIO) ; // vector with NUMSCENARIO = 1000 ints.
	std::iota (std::begin(population), std::end(population), 0); // Fill with 0, 1, ..., 999

	std::vector<int> sample;

/*
	std::experimental::sample(population.begin(), population.end(),
	                std::back_inserter(sample),
					numRepScen,
	                std::mt19937{std::random_device{}()}); //100  randomly chosen values from population vector
*/
	if (numRepScen < Param::NUMSCENARIO){
			std::mt19937 mt(std::random_device{}());
			std::unordered_set<int> sampleset=Random::pickSet(Param::NUMSCENARIO, numRepScen, mt);
			sample.insert(sample.end(), sampleset.begin(), sampleset.end());
		}
	if (numRepScen == Param::NUMSCENARIO){
		for (int i = 0; i < numRepScen; i++)
		sample.push_back(i);
	}

	for (int i = 0; i < Param::NUMINDEX; i++){
		std::vector<std::vector<double>> scenarios;
		for (int j = 0; j < numRepScen; j++){
			scenarios.push_back(irIndexScenario["base"][i][sample[j]]);
		}
		indexScenario[i] = scenarios;
	}



    std::ofstream outfile;
    outfile.open (outputfile);
    outfile << "recordID";
    for (int i = 0; i < indexScenario[0].size(); i++){
    	outfile << ',' << "Scenario"+ std::to_string(i+1);
    }
    outfile << std::endl;


    int numPol = 0;
    std::vector<PolicyResult> resScen;
	#pragma omp parallel for num_threads(2) private(resScen)
    for (int poli = 0; poli<inforce.size();poli++) {
    	Policy policy=inforce[poli];
    	std::cout << "valuing record "
    						<< policy.recordID << std::endl;



		Pricer*  riderPricer = createPricer(policy.productType);
		resScen = riderPricer->evaluateScenario(policy, indexScenario);
		delete riderPricer;
		#pragma omp critical
		{
			outfile << policy.recordID;
			for (int i = 0; i < indexScenario[0].size(); i++){
				outfile << ',' << resScen[i].fmv;
			}

			outfile << std::endl;
			numPol++;
		}
    }
	outfile.close();


    std::cout << "Done valuation." << std::endl;
    std::cout << "Number of policies: " << numPol << std::endl;
}




/*
Pricermain::valuationScenarioCluster(std::string repPolFile, std::string scenariofolder, std::string outputfile){
	std::map<int, std::vector<std::vector<double>>> indexScenario;

	std::vector<int> population(Param::NUMSCENARIO) ; // vector with NUMSCENARIO = 1000 ints.
	std::iota (std::begin(population), std::end(population), 0); // Fill with 0, 1, ..., 999

	std::vector<int> sample;
	std::experimental::sample(population.begin(), population.end(),
	                std::back_inserter(sample),
					numRepScen,
	                std::mt19937{std::random_device{}()}); //100  randomly chosen values from population vector

	for (int i = 0; i < Param::NUMSTEP; i++){
		std::string timefile = scenariofolder+ "/" + "time" + std::to_string(i);
	}
	for (int i = 0; i < Param::NUMINDEX; i++){
		std::vector<std::vector<double>> scenarios;
		for (int j = 0; j < numRepScen; j++){
			scenarios.push_back(irIndexScenario["base"][i][sample[j]]);
		}
		indexScenario[i] = scenarios;
	}


	std::vector<std::string> repPols;
	std::ifstream infile(repPolFile);
	std::string line, data;

	while (std::getline(infile, line))
	{
		if (*line.rbegin() == '\r')
		{
			line.erase(line.length() - 1);
		}
	    std::istringstream iss(line);
	    while (std::getline(iss,data, ',')) {
	    	repPols.push_back(data);
	    }
	    iss.clear();
	}
	infile.close();

    std::ofstream outfile;
    outfile.open (outputfile);
    outfile << "recordID";
    for (int i = 0; i < indexScenario[0].size(); i++){
    	outfile << ',' << "Scenario"+ std::to_string(i+1);
    }
    outfile << std::endl;


    int numPol = 0;
    std::vector<PolicyResult> resScen;
    for (auto const p : repPols){
    	std::cout << "valuing record "
    						<< p << std::endl;
		for (Policy policy : inforce){
			if (policy.recordID != p){
				continue;
			}

			outfile << policy.recordID;
			Pricer*  riderPricer = createPricer(policy.productType);
			resScen = riderPricer->evaluateScenario(policy, indexScenario);
			delete riderPricer;
			for (int i = 0; i < indexScenario[0].size(); i++){
				outfile << ',' << resScen[i].fmv;
			}

			outfile << std::endl;
		}

		numPol++;
    }
	outfile.close();


    std::cout << "Done valuation." << std::endl;
    std::cout << "Number of policies: " << numPol << std::endl;
}

Pricermain::~Pricermain() {
	// TODO Auto-generated destructor stub
}

*/

/*
 * Input: Folder containing files of scenarios of index
 * Output: Run scenarios on representative policies, print to output file
 */
void Pricermain::valuationScenario(std::string scenfolder, std::string outputfile){
	std::map<int, std::vector<std::vector<double>>> indexScenario;
	int  i = 0;
	for (auto const index : param.getIndexMap()){
		std::vector<std::vector<double>> scenario;
		std::string indexfile = index + ".csv";
		std::string scenario_file = scenfolder+ "/" + indexfile;
		std::ifstream infile(scenario_file);
		std::string line, data;

		while (std::getline(infile, line))
		{
			if (*line.rbegin() == '\r')
			{
				line.erase(line.length() - 1);
			}
		    std::istringstream iss(line);
		    std::vector<double> scenarioline;
		    while (std::getline(iss,data, ',')) {
		    	scenarioline.push_back(stod(data));
		    }
		    iss.clear();
		    scenario.push_back(scenarioline);
		}
		infile.close();
		indexScenario[i] = scenario;
		i++;
	}


    std::ofstream outfile;
    outfile.open (outputfile);
    outfile << "recordID";
    for (int i = 0; i < indexScenario[0].size(); i++){
    	outfile << ',' << "Scenario"+ std::to_string(i+1);
    }
    outfile << std::endl;


    int numPol = 0;

	for (auto  const & policy : inforce){

		std::cout << "valuing record "
				<< policy.recordID << std::endl;
		outfile << policy.recordID;

		Pricer*  riderPricer = createPricer(policy.productType);

		std::vector<PolicyResult> resScen = riderPricer->evaluateScenario(policy, indexScenario);
		delete riderPricer;
		for (int i = 0; i < indexScenario[0].size(); i++){
			outfile << ',' << resScen[i].fmv;
		}
		outfile << std::endl;
	numPol++;
    }
	outfile.close();


    std::cout << "Done valuation." << std::endl;
    std::cout << "Number of policies: " << numPol << std::endl;
}
/*
 * Input: file containing representative policies (repPolFile), file containing  representative scenario
 * Output: generate representative scenarios by random sampling, run the scenarios
 * for representative policies and print result to outputfile
 */
void Pricermain::valuationScenarioCorr(std::string repPolFile, std::string repScenFile, std::string outputfile){
	std::map<int, std::vector<std::vector<double>>> indexScenario;

	std::vector<int> sample;
	std::ifstream infile(repScenFile);
	std::string line, data;
	while (std::getline(infile, line))
	{


		if (*line.rbegin() == '\r')
		{
			line.erase(line.length() - 1);
		}
		sample.push_back(std::stoi(line));
	}

	infile.close();
	int numRepScen = sample.size();
	for (int i = 0; i < Param::NUMINDEX; i++){
		std::vector<std::vector<double>> scenarios;
		for (int j = 0; j < numRepScen; j++){
			scenarios.push_back(irIndexScenario["base"][i][sample[j]]);
		}
		indexScenario[i] = scenarios;
	}


	std::vector<std::string> repPols;
	infile.open(repPolFile);

	while (std::getline(infile, line))
	{
		if (*line.rbegin() == '\r')
		{
			line.erase(line.length() - 1);
		}
	    std::istringstream iss(line);
	    while (std::getline(iss,data, ',')) {
	    	repPols.push_back(data);
	    }
	    iss.clear();
	}
	infile.close();

    std::ofstream outfile;
    outfile.open (outputfile);
    outfile << "recordID";
    for (int i = 0; i < indexScenario[0].size(); i++){
    	outfile << ',' << "Scenario"+ std::to_string(i+1);
    }
    outfile << std::endl;


    int numPol = 0;
    std::vector<PolicyResult> resScen;
    for (auto const p : repPols){
    	std::cout << "valuing record "
    						<< p << std::endl;
		for (Policy policy : inforce){
			if (policy.recordID != p){
				continue;
			}

			outfile << policy.recordID;
			Pricer*  riderPricer = createPricer(policy.productType);
			resScen = riderPricer->evaluateScenario(policy, indexScenario);
			delete riderPricer;
			for (int i = 0; i < indexScenario[0].size(); i++){
				outfile << ',' << resScen[i].fmv;
			}

			outfile << std::endl;
		}

		numPol++;
    }
	outfile.close();


    std::cout << "Done valuation." << std::endl;
    std::cout << "Number of policies: " << numPol << std::endl;
}

