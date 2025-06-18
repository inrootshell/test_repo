#include <iostream>

using namespace std;

typedef struct Point2
{
	float x, y;

	explicit Point2() : x(0), y(0) { }

	explicit Point2(float x, float y) : x(x), y(y) { }
} Point2, *Point2Ptr;

int main(int argc, char** argv, char** envp)
{
	Point2 point(3, 5);
	return 0;
}
