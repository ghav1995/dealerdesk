/*
 * test_calc.c - pricing rules, checked against real invoices.
 *
 * The first three cases reproduce invoices 50230-50232 from the sample data,
 * so they pin the rules the business has actually been charging.
 */
#include <math.h>
#include <stdio.h>
#include "calc.h"

static int failures = 0;

static void check(const char *name, const char *field, double actual, double expected)
{
    if (fabs(actual - expected) >= 0.001) {
        printf("  FAIL %s: %s is %.4f, expected %.2f\n", name, field, actual, expected);
        failures++;
    }
}

static void test_retail_invoice_50230(void)
{
    QUOTE q;

    calc_quote(&q, 9295.00, 'R', 5, 1500.00);
    check("50230", "trade_disc", q.trade_disc, 0.00);
    check("50230", "disc", q.disc, 464.75);
    check("50230", "net", q.net, 8830.25);
    check("50230", "vat", q.vat, 1796.05);
    check("50230", "total", q.total, 9331.30);
}

static void test_trade_invoice_50231(void)
{
    QUOTE q;

    calc_quote(&q, 13495.00, 'T', 0, 0);
    check("50231", "trade_disc", q.trade_disc, 1349.50);
    check("50231", "net", q.net, 12145.50);
    check("50231", "vat", q.vat, 2459.10);
    check("50231", "total", q.total, 14809.60);
}

static void test_hand_discount_invoice_50232(void)
{
    QUOTE q;

    calc_quote(&q, 10495.00, 'R', 8, 0);
    check("50232", "disc", q.disc, 839.60);
    check("50232", "net", q.net, 9655.40);
    check("50232", "vat", q.vat, 1961.08);
    check("50232", "total", q.total, 11821.48);
}

static void test_salesman_discount_applies_after_trade(void)
{
    QUOTE q;

    calc_quote(&q, 10000.00, 'T', 10, 0);
    check("after trade", "trade_disc", q.trade_disc, 1000.00);
    check("after trade", "disc", q.disc, 900.00);
    check("after trade", "net", q.net, 8100.00);
}

static void test_salesman_discount_is_limited(void)
{
    QUOTE q;

    calc_quote(&q, 10000.00, 'R', 20, 0);
    check("cap", "disc_pct", q.disc_pct, 15.0);
    check("cap", "disc", q.disc, 1500.00);

    calc_quote(&q, 10000.00, 'R', -5, 0);
    check("floor", "disc_pct", q.disc_pct, 0.0);
    check("floor", "disc", q.disc, 0.00);
}

static void test_fees_and_vat(void)
{
    QUOTE q;

    calc_quote(&q, 1000.00, 'R', 0, 0);
    check("fees", "delivery", q.delivery, 150.00);
    check("fees", "reg_fee", q.reg_fee, 55.00);
    check("fees", "vat on net plus delivery", q.vat, 230.00);
    check("fees", "total", q.total, 1435.00);
}

static void test_trade_in_comes_off_after_vat(void)
{
    QUOTE with_trade_in, without;

    calc_quote(&without, 1000.00, 'R', 0, 0);
    calc_quote(&with_trade_in, 1000.00, 'R', 0, 400.00);
    check("trade-in", "vat unchanged", with_trade_in.vat, without.vat);
    check("trade-in", "total", with_trade_in.total, without.total - 400.00);
}

/* Scenario: Half a penny */
static void test_rounds_half_pennies_up(void)
{
    check("rnd2", "half up", rnd2(10.125), 10.13);
    check("rnd2", "down", rnd2(10.124), 10.12);
}

int main(void)
{
    test_retail_invoice_50230();
    test_trade_invoice_50231();
    test_hand_discount_invoice_50232();
    test_salesman_discount_applies_after_trade();
    test_salesman_discount_is_limited();
    test_fees_and_vat();
    test_trade_in_comes_off_after_vat();
    test_rounds_half_pennies_up();

    if (failures) {
        printf("%d check(s) failed\n", failures);
        return 1;
    }
    printf("all pricing checks passed\n");
    return 0;
}
