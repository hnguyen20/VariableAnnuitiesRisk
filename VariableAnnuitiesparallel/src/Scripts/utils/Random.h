/*
 * Random
 *
 *  Created on: 11Sep.,2021
 *      Author: hangn
 */


#ifndef SRC_SCRIPTS_UTILS_RANDOM_H_
#define SRC_SCRIPTS_UTILS_RANDOM_H_
#include <unordered_set>
#include <random>
class Random {
	public:
		Random();
		virtual ~Random();
		static std::unordered_set<int> pickSet(int, int, std::mt19937&);

};




#endif /* SRC_SCRIPTS_UTILS_RANDOM_H_ */
