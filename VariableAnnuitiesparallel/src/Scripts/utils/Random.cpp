/*
 * Random.cpp
 *
 *  Created on: 11Sep.,2021
 *      Author: hangn
 */
#include <unordered_set>
#include <iostream>
#include "Random.h"
Random::Random() {
}

Random::~Random() {
	// TODO Auto-generated destructor stub
}
std::unordered_set<int> Random::pickSet(int N, int k, std::mt19937& gen)
{
    std::unordered_set<int> elems;
    for (int r = N - k; r < N; ++r) {
        int v = std::uniform_int_distribution<>(1, r)(gen);

        // there are two cases.
        // v is not in candidates ==> add it
        // v is in candidates ==> well, r is definitely not, because
        // this is the first iteration in the loop that we could've
        // picked something that big.

        if (!elems.insert(v).second) {
            elems.insert(r);
        }
    }
    return elems;
}

