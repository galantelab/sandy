#ifndef READ_H
#define READ_H

#define XS_STATE(type, x) \
	INT2PTR(type, SvROK(x) ? SvIV(SvRV(x)) : SvIV(x))

#define XS_STRUCT2OBJ(sv, class, obj) \
	if (obj == NULL) { \
		sv_setsv(sv, &PL_sv_undef); \
	} else { \
		sv_setref_pv(sv, class, (void *) obj); \
	}

typedef struct
{
	gsl_rng * rng;
} RNGContext;

#endif /* READ_H */
