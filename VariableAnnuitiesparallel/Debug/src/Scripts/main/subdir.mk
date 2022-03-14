################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/Scripts/main/runmain.cpp 

OBJS += \
./src/Scripts/main/runmain.o 

CPP_DEPS += \
./src/Scripts/main/runmain.d 


# Each subdirectory must supply rules for building sources it contributes
src/Scripts/main/%.o: ../src/Scripts/main/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: Cygwin C++ Compiler'
	g++ -fopenmp -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


