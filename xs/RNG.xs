#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "sandy_rng.h"
#include "RNG.h"

MODULE = App::Sandy::RNG		PACKAGE = App::Sandy::RNG

PROTOTYPES: DISABLED

RNGContext *
App::Sandy::RNG::new (unsigned long seed)
	PREINIT:
		RNGContext *ctx;
	CODE:
		Newx (ctx, 1, RNGContext);
		ctx->rng = gsl_rng_alloc (gsl_rng_ranlxd2);
		gsl_rng_set (ctx->rng, seed);
		RETVAL = ctx;
	OUTPUT:
		RETVAL

void
DESTROY (RNGContext *ctx)
	CODE:
		Safefree (ctx->rng);
		Safefree (ctx);

void
set (RNGContext *ctx, unsigned long seed)
	CODE:
		gsl_rng_set (ctx->rng, seed);

unsigned long
max (RNGContext *ctx)
	CODE:
		RETVAL = gsl_rng_max (ctx->rng);
	OUTPUT:
		RETVAL

unsigned long
min (RNGContext *ctx)
	CODE:
		RETVAL = gsl_rng_min (ctx->rng);
	OUTPUT:
		RETVAL

size_t
size (RNGContext *ctx)
	CODE:
		RETVAL = gsl_rng_size (ctx->rng);
	OUTPUT:
		RETVAL

char *
name (RNGContext *ctx)
	CODE:
		RETVAL = (char *) gsl_rng_name (ctx->rng);
	OUTPUT:
		RETVAL

unsigned long
get (RNGContext *ctx)
	CODE:
		RETVAL = gsl_rng_get (ctx->rng);
	OUTPUT:
		RETVAL

double
uniform (RNGContext *ctx)
	CODE:
		RETVAL = gsl_rng_uniform (ctx->rng);
	OUTPUT:
		RETVAL

double
uniform_pos (RNGContext *ctx)
	CODE:
		RETVAL = gsl_rng_uniform_pos (ctx->rng);
	OUTPUT:
		RETVAL

double
ran_gaussian (RNGContext *ctx, double sigma)
	CODE:
		RETVAL = gsl_ran_gaussian (ctx->rng, sigma);
	OUTPUT:
		RETVAL

double
ran_gaussian_ratio_method (RNGContext *ctx, double sigma)
	CODE:
		RETVAL = gsl_ran_gaussian_ratio_method (ctx->rng, sigma);
	OUTPUT:
		RETVAL

double
ran_gaussian_pdf (double x, double sigma)
	CODE:
		RETVAL = gsl_ran_gaussian_pdf (x, sigma);
	OUTPUT:
		RETVAL

double
ran_ugaussian (RNGContext *ctx)
	CODE:
		RETVAL = gsl_ran_ugaussian (ctx->rng);
	OUTPUT:
		RETVAL

double
ran_ugaussian_ratio_method (RNGContext *ctx)
	CODE:
		RETVAL = gsl_ran_ugaussian_ratio_method (ctx->rng);
	OUTPUT:
		RETVAL

double
ran_ugaussian_pdf (double x)
	CODE:
		RETVAL = gsl_ran_ugaussian_pdf (x);
	OUTPUT:
		RETVAL

unsigned long
get_n (RNGContext *ctx, unsigned long n)
	INIT:
		if (n <= 0)
			croak ("n must be greater than zero");
	CODE:
		RETVAL = gsl_rng_get (ctx->rng) % n;
	OUTPUT:
		RETVAL

double
get_norm (RNGContext *ctx, double mean, double stdd)
	CODE:
		RETVAL = mean + (int) (gsl_ran_gaussian (ctx->rng, stdd) + 0.5);
	OUTPUT:
		RETVAL
