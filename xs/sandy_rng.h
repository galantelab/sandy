#ifndef __GSL_RNG_H__
#define __GSL_RNG_H__

#include <stdlib.h>

/* From gsl_math.h */
#ifndef M_PI
# define M_PI       3.14159265358979323846264338328      /* pi */
#endif

typedef struct
  {
    const char *name;
    unsigned long int max;
    unsigned long int min;
    size_t size;
    void (*set) (void *state, unsigned long int seed);
    unsigned long int (*get) (void *state);
    double (*get_double) (void *state);
  }
gsl_rng_type;

typedef struct
  {
    const gsl_rng_type * type;
    void *state;
  }
gsl_rng;

extern const gsl_rng_type *gsl_rng_ranlxd2;

gsl_rng *gsl_rng_alloc (const gsl_rng_type * T);
void gsl_rng_free (gsl_rng * r);

void gsl_rng_set (const gsl_rng * r, unsigned long int seed);
unsigned long int gsl_rng_max (const gsl_rng * r);
unsigned long int gsl_rng_min (const gsl_rng * r);
const char *gsl_rng_name (const gsl_rng * r);

size_t gsl_rng_size (const gsl_rng * r);
void * gsl_rng_state (const gsl_rng * r);

static inline unsigned long int
gsl_rng_get (const gsl_rng * r)
{
  return (r->type->get) (r->state);
}

static inline double
gsl_rng_uniform (const gsl_rng * r)
{
  return (r->type->get_double) (r->state);
}

static inline double
gsl_rng_uniform_pos (const gsl_rng * r)
{
  double x ;
  do
    {
      x = (r->type->get_double) (r->state) ;
    }
  while (x == 0) ;

  return x ;
}

double gsl_ran_gaussian (const gsl_rng * r, const double sigma);
double gsl_ran_gaussian_ratio_method (const gsl_rng * r, const double sigma);
double gsl_ran_gaussian_pdf (const double x, const double sigma);
double gsl_ran_ugaussian (const gsl_rng * r);
double gsl_ran_ugaussian_ratio_method (const gsl_rng * r);
double gsl_ran_ugaussian_pdf (const double x);

#endif /* __GSL_RNG_H__ */
