# Findings and recommendations

## Executive summary

57.3% of DataCo's orders arrive late (36,048 of 62,897 non-canceled orders, Jan 2015 to Jan 2018). Those orders carry $20.1M in sales and $2.14M in profit, 57% and 56% of the totals. Lateness is not seasonal, regional or tied to product: it is set by the shipping mode, because First Class and Second Class promise delivery times shorter than DataCo actually delivers. Lengthening those promises is the fastest fix: +1 day on every promise cuts the late rate to 23.7%, +2 days to 7.8%.

## Findings

1. **Shipping mode is the strongest driver.** Late rate by mode: First Class 100%, Second Class 80%, Same Day 48%, Standard Class 40%. First Class (9,602 orders) is late every time.
2. **The promises are shorter than the delivery time.** First Class promises 1 day and always takes 2. Second Class promises 2 days but takes 2 to 6, spread almost evenly. Standard Class promises 4 days and takes 2 to 6, so 40% land late.
3. **Nothing else explains it.** The late rate stays between 55% and 60% in every month; inside each shipping mode it is about the same in every region; the nine largest categories are all 56.9% to 57.6% late.
4. **The money at stake is large.** Late orders carry $20,126,395 in sales and $2,140,052 in profit.

## Recommendations

1. **Reset First Class to a 2-day promise.** It always takes 2 days, so this removes lateness on 9,602 orders (100% to 0%) with no change in operations.
2. **Fix Second Class at the carrier level, then set its promise from data.** Delivery takes 2 to 6 days, so even +2 days leaves 40% late. Find out why the spread is so wide before choosing a promise.
3. **Track promise accuracy monthly by shipping mode** (promised days, actual days, late rate) so a promise that drifts from reality is caught early. The Power BI report already does this.

What-if, all modes: +1 day gives 23.7% late (First Class 0%, Second Class 60.2%, Same Day 0%, Standard Class 20%); +2 days gives 7.8% (Second Class 40%, all others 0%).

## Limits

- Public, synthetic-looking data: actual delivery days are spread almost evenly across 2 to 6 (issues log #17), and order volume steps up from Oct 2017 (#16). Treat percentages as a demonstration of method, not as real DataCo performance.
- No carrier or cost data, so the recommendations cannot say what faster delivery would cost.
- The what-if changes the promise, not the performance; longer promises may also cost sales.
- Canceled and suspected-fraud orders (7,754 lines) are excluded. Categories are counted in order lines, everything else per order. Differences in small cells are noise.
