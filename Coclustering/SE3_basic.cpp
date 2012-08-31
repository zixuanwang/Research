#include <cmath>
#include "SE3_basic.h"

static void SE3_compute_exp_coefs(double theta,
								  double &A, double &B, double &C)
{
	static const double one = 1;
	static const double half = one/2;
	static const double sixth = one/6;
	static const double twelfth = one/12;
	static const double twentieth = one/20;
	static const double thirtieth = one/30;
	static const double forty_second = one/42;

	const double theta_sq = theta * theta;
	if (theta_sq < 1e-5) {
		// Taylor expansions near theta == 0
		A = 1 - theta_sq * sixth * (1 - theta_sq * twentieth);
		B = half*(1 - theta_sq*twelfth*(1 - theta_sq*thirtieth));
		C = sixth*(1 - theta_sq*twentieth*(1 - theta_sq*forty_second));
	} else {
		const double inv_theta = 1/theta;
		const double inv_theta_sq = inv_theta * inv_theta;
		A = sin(theta) * inv_theta;
		B = (1 - cos(theta)) * inv_theta_sq;
		C = (1 - A) * inv_theta_sq;
	}
}

static void SE3_build_exp_matrix(const double w[3], double A, double B,
								 double Q[9])
{
	Q[0] = 1 - B * (w[1]*w[1] + w[2]*w[2]);
	Q[4] = 1 - B * (w[0]*w[0] + w[2]*w[2]);
	Q[8] = 1 - B * (w[0]*w[0] + w[1]*w[1]);

	Q[1] = B*w[0]*w[1] - A*w[2];
	Q[3] = B*w[0]*w[1] + A*w[2];

	Q[2] = B*w[0]*w[2] + A*w[1];
	Q[6] = B*w[0]*w[2] - A*w[1];

	Q[5] = B*w[1]*w[2] - A*w[0];
	Q[7] = B*w[1]*w[2] + A*w[0];
}

static void cross_product(double axb[3], const double a[3], const double b[3])
{
	axb[0] = a[1]*b[2] - a[2]*b[1];
	axb[1] = a[2]*b[0] - a[0]*b[2];
	axb[2] = a[0]*b[1] - a[1]*b[0];
}

void SE3_exp(SE3& expv, const double v[6])
{
	const double *u = v;
	const double *w = v+3;
	double theta = sqrt(w[0]*w[0] + w[1]*w[1] + w[2]*w[2]);

	double A, B, C;
	SE3_compute_exp_coefs(theta, A, B, C);

	SE3_build_exp_matrix(w, A, B, expv.R);
	
	double wxu[3];
	cross_product(wxu, w, u);
	
	double wxwxu[3];
	cross_product(wxwxu, w, wxu);

	for (int i=0; i<3; ++i) {
		expv.t[i] = u[i] + B*wxu[i] + C*wxwxu[i];
	}
}

SE3 SE3_mult(const SE3 &a, const SE3& b)
{
	SE3 ab;
	for (int i=0; i<3; ++i) {
		const double *ai = &a.R[i*3];
		double Rti = 0;
		for (int j=0; j<3; ++j) {
			double s = 0;
			for (int k=0; k<3; ++k) {
				s += ai[k] * b.R[k*3 + j];
			}
			ab.R[i*3 + j] = s;
			Rti += ai[j] * b.t[j];
		}
		ab.t[i] = Rti + a.t[i];
	}
	return ab;
}

static void normalize3(double x[3])
{
	double factor = 1.0/sqrt(x[0]*x[0] + x[1]*x[1] + x[2]*x[2]);
	x[0] *= factor;
	x[1] *= factor;
	x[2] *= factor;
}

static double dot3(const double a[3], const double b[3])
{
	return a[0]*b[0] + a[1]*b[1] + a[2]*b[2];
}

void SE3_rectify(SE3 &s)
{
	normalize3(&s.R[0]);
	double ab = dot3(&s.R[0], &s.R[3]);
	for (int i=0; i<3; ++i)
		s.R[3+i] -= ab * s.R[i];
	normalize3(&s.R[3]);
	cross_product(&s.R[6], &s.R[0], &s.R[3]);
}

#if SE3_TEST

#include <cstdio>

static void SE3_print(const SE3 &pose)
{
	for (int i=0; i<3; ++i) {
		for (int j=0; j<3; ++j) {
			printf("%16f ", pose.R[i*3+j]);
		}
		printf("%16f\n", pose.t[i]);
	}
}

int main()
{
	double v[6] = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6 };
	SE3 pose;
	SE3_exp(pose, v);
	
	pose = SE3_mult(pose, pose);
	
	SE3_print(pose);
	
	return 0;
}

#endif
