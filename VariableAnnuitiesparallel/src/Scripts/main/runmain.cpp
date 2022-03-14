
#include "../pricing/Pricermain.h"
#include <iostream>
#include <fstream>
#include <chrono>
#include "../../Data/Param.h"

int main() {
	//inforcefile, fmvfile is the test run of fair market value
	//inforcefile_full, fmvfile_full is the full data by Gan.
	//inforcecluster is the inforce file with fair market values for data analysis
	std::string inforcefile, inforcefile_full, inforcecluster, clusterscenariofolder,
	funcclusterscenariofolder,
		fmvfile, fmvfile_full, clusterIFfile, mapfile, greekfile,scenarioresultfolder,
		regressionfolder, scenariofolder, repPolFile, regPol;
	inforcefile = "./src/Data/inforce_small.csv";
	inforcefile_full = "./src/Data/inforce_full.csv";
	inforcecluster = "./src/Data/inforce_cluster.csv";

	 //scenariofolder = "./src/Result/inforcevaluation/RN10000/"; //For 10,000 scenarios
	//scenariofolder = "./src/Result/inforcevaluation/RN/";
	scenariofolder = "./src/Result/inforcevaluation/RW10000/";

	funcclusterscenariofolder = "./src/Result/inforcevaluation/RN/base/Scen50ver2/";
	// Fair market value and partial account value result files
	fmvfile = "./src/Result/inforcevaluation/fmv_seriatim_test.csv";
	fmvfile_full = "./src/Result/inforcevaluation/fmv_seriatim_full.csv";

	clusterIFfile = "./src/Result/inforcevaluation/clusterIF.csv";
	mapfile = "./src/Result/inforcevaluation/MapFileBase.csv";
	greekfile = "./src/Result/inforcevaluation/Greek.csv";
	scenarioresultfolder = "./src/Result/inforcevaluation/ScenarioResult/";

	/*10000 scenarios
	regressionfolder = "./src/Data/Regression10000/";
	repPolFile = 	regressionfolder + "repPolicy2000.csv";
	regPol = regressionfolder + "regPolicy2000.csv";
*/
	regressionfolder = "./src/Data/RegressionResult/IndividualPlot/";
	repPolFile = 	regressionfolder + "repPols200.csv";
	//regPol = regressionfolder + "regPols200RW1000.csv";
	regPol = regressionfolder + "inforcetestscenario10000.csv";

	std::string rep = 	regressionfolder + "repPolicy";
	std::string reg = regressionfolder + "regPolicy";

	std::string scenarioresult = regressionfolder + "scenResult50randomver2_10000.csv";

	//"ABRP", "ABRU", "ABSU", "DBAB", "DBIB",
//    "DBMB", "DBRP", "DBRU", "DBSU", "DBWB",
//    "IBRP", "IBRU", "IBSU", "MBRP", "MBRU",
//    "MBSU", "WBRP", "WBRU", "WBSU"

	std::string replist[19] = {rep +"ABRP.csv", rep + "ABRU.csv", rep + "ABSU.csv",
								rep + "DBAB.csv", rep+"DBIB.csv", rep + "DBMB.csv",
								rep+"DBRP.csv", rep+"DBRU.csv", rep+"DBSU.csv", rep+"DBWB.csv",
							rep+"IBRP.csv", rep+"IBRU.csv", rep+"IBSU.csv", rep+"MBRP.csv", rep+"MBRU.csv",
							rep+"MBSU.csv", rep+"WBRP.csv", rep+"WBRU.csv", rep+"WBSU.csv"};
	std::string reglist[19] = {reg +"ABRP.csv", reg + "ABRU.csv", reg + "ABSU.csv",
			reg + "DBAB.csv", reg+"DBIB.csv", reg + "DBMB.csv",
			reg+"DBRP.csv", reg+"DBRU.csv", reg+"DBSU.csv", reg+"DBWB.csv",
		reg+"IBRP.csv", reg+"IBRU.csv", reg+"IBSU.csv", reg+"MBRP.csv", reg+"MBRU.csv",
		reg+"MBSU.csv", reg+"WBRP.csv", reg+"WBRU.csv", reg+"WBSU.csv"};

	//Output fairmarket values for various shock scenarios
	//Remember to change file Param.h if run 10,000 scenarios
	Pricermain p(inforcefile,scenariofolder);

	std::chrono::steady_clock::time_point begin1 = std::chrono::steady_clock::now();
	p.valuationScenario(10000,regPol);
	//p.valuationScenario(repPolFile,1000,regPol);
	//p.valuationScenario(repPolFile,funcclusterscenariofolder,scenarioresult);
	//p.valuationScenario(repPolFile,50,scenarioresult);
	std::chrono::steady_clock::time_point end1 = std::chrono::steady_clock::now();
	std::cout << "Time difference = " << std::chrono::duration_cast<std::chrono::microseconds>(end1 - begin1).count()/1000000 << "[s]" << std::endl;

	//p.valuation(fmvfile);
//p.valuationScenario(repPolFile,1000,regPol);

//	p.printInforce(fmvfile_full, inforcecluster);

/*
for (int i = 0; i < 19; i++){
	//p.valuationScenario(replist[i], "./src/Result/inforcevaluation/RN/base",reglist[i]);
	p.valuationScenarioCorr(replist[i], "./src/Data/Regression_trajectoryclusteringcorrelation/trajectorycorrelation.csv",reglist[i]);
}
*/





	//
//	p.valuationScenario(10,scenarioresult);
//	p.valuationScenario(rep +"ABRP.csv", 1000,reg +"ABRP.csv");

//	p.valuationScenario(repPolFile, 100,regPol);

//	p.valuation(fmvfile);

	/*
	std::chrono::steady_clock::time_point begin2 = std::chrono::steady_clock::now();
	p.valuationScenario(100, scenarioresultfolder);
	std::chrono::steady_clock::time_point end2 = std::chrono::steady_clock::now();
	std::cout << "Scenario Run Time difference = " << std::chrono::duration_cast<std::chrono::microseconds>(end2 - begin2).count()/1000000 << "[s]" << std::endl;
*/





	return 1;

}


