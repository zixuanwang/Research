struct SE3
{
	double R[9]; // row major
	double t[3];
};

// Compute exp(v) and store in expv
void SE3_exp(SE3& expv, const double v[6]);

// Returns a * b
SE3 SE3_mult(const SE3 &a, const SE3& b);

// Orthonormalizes rotation part of s
// After many multiplies the rotation might degrade due
// to numerical precision, so this should be called periodically.
void SE3_rectify(SE3 &s);

