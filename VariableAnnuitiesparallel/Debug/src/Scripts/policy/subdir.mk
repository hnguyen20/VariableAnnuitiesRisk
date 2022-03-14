################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/Scripts/policy/Policy.cpp 

OBJS += \
./src/Scripts/policy/Policy.o 

CPP_DEPS += \
./src/Scripts/policy/Policy.d 


# Each subdirectory must supply rules for building sources it contributes
src/Scripts/policy/%.o: ../src/Scripts/policy/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: Cygwin C++ Compiler'
	g++ -fopenmp -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


