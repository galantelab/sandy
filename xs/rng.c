#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "sandy_rng.h"

#define GSL_RNG_DEFAULT_SEED 1717

#define error(msg) \
	do { \
		fprintf (stderr, msg ": %s\n" , strerror (errno)); \
		abort (); \
	} while (0)

gsl_rng *
gsl_rng_alloc (const gsl_rng_type * T)
{
  gsl_rng *r = (gsl_rng *) malloc (sizeof (gsl_rng));

  if (r == NULL)
    error ("failed to allocate space for rng struct");

  r->state = calloc (1, T->size);

  if (r->state == NULL)
    {
      free (r);
      error ("failed to allocate space for rng state");
    }

  r->type = T;

  gsl_rng_set (r, GSL_RNG_DEFAULT_SEED);

  return r;
}

void
gsl_rng_set (const gsl_rng * r, unsigned long int seed)
{
  (r->type->set) (r->state, seed);
}

unsigned long int
gsl_rng_max (const gsl_rng * r)
{
  return r->type->max;
}

unsigned long int
gsl_rng_min (const gsl_rng * r)
{
  return r->type->min;
}

const char *
gsl_rng_name (const gsl_rng * r)
{
  return r->type->name;
}

size_t
gsl_rng_size (const gsl_rng * r)
{
  return r->type->size;
}

void *
gsl_rng_state (const gsl_rng * r)
{
  return r->state;
}

void
gsl_rng_free (gsl_rng * r)
{
  if (r == NULL)
    return;
  free (r->state);
  free (r);
}
