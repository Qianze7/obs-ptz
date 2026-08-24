#include "test_config.hpp"

TestConfig &testConfig()
{
	static TestConfig config;
	return config;
}
