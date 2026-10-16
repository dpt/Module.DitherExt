/* DitherExtend SetScreen. Ported from DitherExt.s. The fixed-point helpers
   (Sine, ScreenSpot, Divide16) follow the original bit for bit. */

#include "colour.h"

#define LATTICE_MAX 0x400u
#define SPOT_ONE    0x1000000

typedef int32_t (*SpotFn)(int32_t x, int32_t y);

static uint32_t mul_u(uint32_t a, uint32_t b)
{
    uint32_t ah = a >> 16;
    uint32_t bh = b >> 16;
    uint32_t cross1 = bh * (a & 0xFFFF);
    uint32_t cross2 = ah * (b & 0xFFFF);
    uint32_t high = ah * bh;
    uint32_t sum = cross1 + cross2;

    if (sum < cross1)
        high += 0x10000;
    return high + (sum >> 16) + ((sum >> 15) & 1);
}

/* MultiplySigned16: the second operand is unsigned. */
static int32_t mul_s(int32_t a, uint32_t b)
{
    uint32_t m = mul_u(a < 0 ? -(uint32_t)a : (uint32_t)a, b);

    return a < 0 ? -(int32_t)m : (int32_t)m;
}

static uint32_t square16(uint32_t x)
{
    uint32_t hi = x >> 16;
    uint32_t cross = hi * (x & 0xFFFF);

    return hi * hi + (cross >> 15) + ((cross >> 14) & 1);
}

/* Reduce an angle in 1/65536 degree to -45..45 degrees plus an octant count
   whose low two bits select the polynomial and its sign. */
static int32_t reduce_angle(int32_t angle, uint32_t *quadrant)
{
    uint32_t unit = 0x2D0000;
    uint32_t a = angle < 0 ? -(uint32_t)angle : (uint32_t)angle;
    uint32_t q = 0;
    int32_t red;

    a %= unit << 3;
    if (a >= unit << 2) {
        a -= unit << 2;
        q = 1;
    }
    q <<= 1;
    if (a >= unit << 1) {
        a -= unit << 1;
        q |= 1;
    }
    red = (int32_t)a;
    if (a >= unit) {
        red = (int32_t)(a - (unit << 1));
        q++;
    }
    if (angle < 0) {
        red = -red;
        q = -q;
    }
    *quadrant = q;
    return red;
}

/* The two polynomials of Sine_1 and ScreenSpot_1. 'table' holds the five
   coefficients, 'odd' selects the one that is finally multiplied by the angle. */
static int32_t polynomial(int32_t red, int negate, int odd)
{
    static const uint32_t sine_table[5] = { 0xF7C13513, 0x5863091F, 0x426C4015, 0x4FDA8761, 0x40000000 };
    static const uint32_t spot_table[5] = { 0xF6D1DFA9, 0x70D72AE3, 0x76B64F55, 0x76EE0831, 0x477D1A89 };
    const uint32_t *t = odd ? spot_table : sine_table;
    uint32_t x = red < 0 ? -(uint32_t)red : (uint32_t)red;
    uint32_t x2;
    int32_t v;

    x2 = square16(x << 10);
    v = (int32_t)(mul_u(x2, t[0]) >> 7) - (int32_t)t[1];
    v = (int32_t)t[2] + (mul_s(v, x2) >> 5);
    v = (mul_s(v, x2) >> (odd ? 4 : 3)) - (int32_t)t[3];
    v = (int32_t)t[4] + (mul_s(v, x2) >> (odd ? 3 : 1));
    if (negate)
        v = -v;
    if (odd) {
        int flag = v < 0;
        int32_t m = mul_s(v, x << 10);

        return flag ? -m : m;
    }
    return v;
}

static int32_t trig(int32_t angle, uint32_t phase)
{
    uint32_t q;
    int32_t red = reduce_angle(angle, &q);

    q += phase;
    return polynomial(red, (q >> 1) & 1, !(q & 1));
}

/* Divide16: |value| / divisor as a rounded 16.16 number with the sign of
   value. Saturates when the divisor is too large. */
static int32_t divide16(uint32_t divisor, int32_t value)
{
    uint32_t d = divisor;
    uint32_t n = value < 0 ? -(uint32_t)value : (uint32_t)value;
    uint32_t q = 0;
    uint32_t t;
    int32_t skip = 14;
    int32_t i;
    int c;

    if (value == 0)
        return 0;
    if (d < n) {
        if (d <= n >> 16) { d <<= 16; skip -= 16; }
        if (d <= n >> 8)  { d <<= 8;  skip -= 8; }
        if (d <= n >> 4)  { d <<= 4;  skip -= 4; }
        if (d <= n >> 2)  { d <<= 2;  skip -= 2; }
        if (d <= n >> 1)  { d <<= 1;  skip -= 1; }
    }
    c = n >= d;
    if (c)
        n -= d;
    q = c;
    if (skip < 0)
        return value >= 0 ? 0x7FFFFFFF : (int32_t)0x80000000;
    for (i = skip; i < 30; i++) {
        t = n << 1;
        c = t >= d;
        n = c ? t - d : t;
        q = q * 2 + c;
    }
    t = n << 1;
    q += t >= d;
    return value < 0 ? -(int32_t)q : (int32_t)q;
}

static int32_t round16(int32_t v)
{
    return (v >> 16) + ((v >> 15) & 1);
}

#define ABS(v) ((v) < 0 ? -(v) : (v))

static uint32_t spot_sum(int32_t x, int32_t y)
{
    return (uint32_t)((y >> 1) * y + (x >> 1) * x);
}

/* Shared tail of spot_round and spot_round_5: x and y are already positive. */
static int32_t spot_edge(int32_t x, int32_t y)
{
    int outside = x + y > 0x10000;
    int32_t t;

    if (outside) {
        x = 0x10000 - x;
        y = 0x10000 - y;
    }
    t = (int32_t)(spot_sum(x, y) >> 7);
    return outside ? t - SPOT_ONE : SPOT_ONE - t;
}

static int32_t spot_round(int32_t x, int32_t y)
{
    return spot_edge(ABS(x), ABS(y));
}

static int32_t spot_round_2(int32_t x, int32_t y)
{
    uint32_t t = spot_sum(x, y);

    return (int32_t)((t >> 7) + ((t >> 6) & 1));
}

static int32_t spot_round_1(int32_t x, int32_t y)
{
    return SPOT_ONE - spot_round_2(x, y);
}

static int32_t spot_round_3(int32_t x, int32_t y)
{
    (void)x;
    return ABS(y);
}

static int32_t spot_round_4(int32_t x, int32_t y)
{
    x = ABS(x);
    y = ABS(y);
    return x <= y ? x : y;
}

static int32_t fold(int32_t v)
{
    v = (int32_t)((uint32_t)v << 1);
    v = ABS(v);
    v -= 0x10000;
    return ABS(v);
}

static int32_t spot_round_5(int32_t x, int32_t y)
{
    return spot_edge(fold(x), fold(y));
}

#ifndef HOST_TEST
/* User spot function: R0 = x and R1 = y in, R2 = result out. */
static int32_t call_user(uint32_t fn, int32_t x, int32_t y)
{
    register int32_t r0 __asm__("r0") = x;
    register int32_t r1 __asm__("r1") = y;
    register int32_t r2 __asm__("r2");

    __asm__ volatile("mov lr, pc\n\tmov pc, %3"
                     : "+r"(r0), "+r"(r1), "=r"(r2)
                     : "r"(fn)
                     : "r3", "lr", "memory", "cc");
    return r2;
}
#endif

static int32_t spot_call(int32_t selector, int32_t x, int32_t y)
{
    switch (selector) {
    case -1: return spot_round(x, y);
    case -2: return spot_round_1(x, y);
    case -3: return spot_round_2(x, y);
    case -4: return spot_round_3(x, y);
    case -5: return spot_round_4(x, y);
    case -6: return spot_round_5(x, y);
    default:
#ifdef HOST_TEST
        return 0;
#else
        return call_user((uint32_t)selector, x, y);
#endif
    }
}

/* Step a lattice coordinate back by d, wrapping at the area. */
#define WALK(v, d) do { v -= (d); if (v < 0) v += area; } while (0)

/* Build the threshold bytes into 'thr' and report the SetHalftone values
   *width, *height and *shift. */
_kernel_oserror *set_screen_core(int32_t fn, int32_t angle, int32_t sx, int32_t sy,
                                 int32_t arg, uint8_t *thr,
                                 uint32_t *width, uint32_t *height, uint32_t *shift)
{
    uint32_t spot[LATTICE_MAX];
    int32_t sl;
    int32_t fp;
    int32_t a;
    int32_t b;
    int32_t c;
    int32_t d;
    int32_t area;
    int32_t acc;
    int32_t step;
    int32_t count;
    int32_t r0;
    int32_t r1;
    int32_t r2;
    int32_t r3;
    int32_t col;
    uint32_t i;
    uint32_t n;
    uint32_t j;
    uint32_t best;
    uint32_t pick;
    uint32_t guard;

    sl = trig(angle, 1);
    sl = (sl >> 14) + ((sl >> 13) & 1);
    fp = trig(angle, 0);
    fp = (fp >> 14) + ((fp >> 13) & 1);
    for (;;) {
        a = round16(divide16(arg, sl * sy));
        b = round16(divide16(arg, -(fp * sy)));
        c = round16(divide16(arg, fp * sx));
        d = round16(divide16(arg, sl * sx));
        sl = a * d;
        fp = b * c;
        area = ABS(sl) + ABS(fp);
        if (area != 0)
            break;
        if (sx == 0 && sy == 0)     /* the original loops forever here */
            return make_error(0x803004, "Screen size too large");
        sx <<= 1;
        sy <<= 1;
    }
    if ((uint32_t)area > LATTICE_MAX)
        return make_error(0x803004, "Screen size too large");

    r0 = ABS(a);
    r1 = ABS(b);
    r2 = 0;
    r3 = 0;
    count = 0;
    guard = 0;
    do {
        count++;
        WALK(r2, r0);
        WALK(r3, r1);
    } while ((r2 | r3) != 0 && guard++ < 0x100000);
    *width = count;

    acc = area;
    step = 0;
    do {
        step++;
        acc -= count;
        if (acc != 0) {
            step++;
            acc -= count;
            if (acc != 0) {
                step++;
                acc -= count;
            }
        }
    } while (acc > 0);
    *height = step;

    r2 = a < 0 ? -c : c;
    r3 = b < 0 ? -d : d;
    r2 = -step * r2 % area;
    r3 = -step * r3 % area;
    if (r2 < 0)
        r2 += area;
    if (r3 < 0)
        r3 += area;
    sl = 0;
    fp = 0;
    count = 0;
    guard = 0;
    while ((sl != r2 || fp != r3) && guard++ < 0x100000) {
        count++;
        WALK(sl, r0);
        WALK(fp, r1);
    }
    *shift = count;

    a = divide16(area, a);
    b = divide16(area, b);
    c = divide16(area, c);
    d = divide16(area, d);
    if (area & 1) {
        r0 = 0;
        r1 = 0;
    } else {
        r0 = a + b;
        r1 = c + d;
    }
    r0 += 0x11;
    r1 += 0x21;
    n = area;
    col = 0;
    for (i = 0; i < n; i++) {
        spot[i] = (uint32_t)(spot_call(fn, r0, r1) + SPOT_ONE);
        if (i + 1 == n)
            break;
        col++;
        if (*width == (uint32_t)col) {
            col = 0;
            r0 += c * 2;
            r1 += d * 2;
        }
        r0 += a * 2;
        r1 += b * 2;
        r0 = (int32_t)((uint32_t)r0 << 15) >> 15;
        r1 = (int32_t)((uint32_t)r1 << 15) >> 15;
    }

    step = divide16(n, 0xFF0);
    if ((uint32_t)(step * (int32_t)n - step) >= 0xFF00)
        step--;
    acc = step >> 1;
    pick = 0;
    for (i = 0; i < n; i++) {
        best = 0xFFFFFFFF;
        for (j = 0; j < n; j++) {
            if (best > spot[j]) {
                best = spot[j];
                pick = j;
            }
        }
        spot[pick] = 0xFFFFFFFF;
        thr[pick] = (uint8_t)((uint32_t)acc >> 20);
        acc += step;
    }
    return NULL;
}

_kernel_oserror *swi_set_screen(_kernel_swi_regs *r)
{
    uint32_t width;
    uint32_t height;
    uint32_t shift;
    _kernel_oserror *e;

    e = set_screen_core(r->r[0], r->r[1], r->r[2], r->r[3], r->r[4],
                        (uint8_t *)ws.thresholds, &width, &height, &shift);
    if (e != NULL)
        return e;
    ws.halftone[0] = (uint32_t)(uintptr_t)ws.thresholds;
    ws.halftone[1] = width;
    ws.halftone[2] = height;
    ws.halftone[3] = shift;
    ws.halftone[4] = r->r[5];
    ws.halftone[5] = r->r[6];
    ws.halftone[6] = 0;
    ws.halftone[7] = 0;
    return NULL;
}
