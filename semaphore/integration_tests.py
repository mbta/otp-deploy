#/usr/bin/env python
from datetime import date, time, datetime, timedelta
from random import randrange, getrandbits
import json
import requests

SPLUNK_HOST = "https://mbta.splunkcloud.com:8089"
SAVED_SEARCH = "Top 10 trip plans %2B 10 latest trip plans"
OTP_DEV = "https://dev.otp.mbtace.com"
OTP_PROD = "https://prod.otp.mbtace.com"


def splunk_json_request(path):
    return requests.get(f"{SPLUNK_HOST}{path}",
                        params={"output_mode": "json"},
                        auth=("lboyarsky@mbta.com", "XXX"),
                        verify=False).json()


def splunk_get_search_name():
    data = splunk_json_request(f"/services/saved/searches/{SAVED_SEARCH}/history")

    if "entry" not in data or len(data.get("entry")) < 1 or "name" not in data.get("entry")[0]:
        raise RuntimeError("Unable to get results reference from splunk")

    return data.get("entry")[0].get("name")


def splunk_get_search_results(name):
    data = splunk_json_request(f"/services/search/jobs/{name}/results")

    if "results" not in data or len(data.get("results")) <= 10:
        raise RuntimeError("Unable to get trip data from splunk")

    return [{r.get("fromPlace"), r.get("toPlace")} for r in data.get("results")]


def get_testing_dates():
    # returns random times on next Wednesday and next Sunday

    tomorrow = (
        datetime.combine(date.today() + timedelta(days=1), time(randrange(6, 21), randrange(0, 59)))
    )

    return {tomorrow + timedelta(days=(2 - tomorrow.weekday()) % 7),
            tomorrow + timedelta(days=(6 - tomorrow.weekday()) % 7)}


def get_trip_plans(environment, from_place, to_place, trip_date, arrive_by):
    url = f"{(OTP_PROD if environment == 'prod' else OTP_DEV)}/otp/routers/default/plan"

    params = {
        "fromPlace": from_place,
        "toPlace": to_place,
        "date": trip_date.strftime("%Y-%m-%d"),
        "time": trip_date.strftime("%I:%M%p"),
        "showIntermediateStops": "true",
        "format": "json",
        "locale": "en",
        "mode": "TRAM,SUBWAY,FERRY,RAIL,BUS,WALK",
        "walkReluctance": "5",
        "arriveBy": "true" if arrive_by else "false"
    }

    return requests.get(url, params).json()


def compare_plans(plan1, plan2):
    try:
        assert ("plan" in plan1) == ("plan" in plan2)

        if "plan" in plan1:
            assert ("itineraries" in plan1.get("plan")) == ("itineraries" in plan2.get("plan"))

            if "itineraries" in plan1.get("plan"):
                j1 = json.dumps(plan1.get("plan").get("itineraries"), sort_keys=True)
                j2 = json.dumps(plan2.get("plan").get("itineraries"), sort_keys=True)

                assert j1 == j2

        print("[PASS] Plans are identical, moving on\n")

    except AssertionError as ex:
        print("[FAIL] Plans are different:\n")
        print(f"  First plan: {json.dumps(plan1, sort_keys=True)}\n\n\n")
        print(f"  First plan: {json.dumps(plan2, sort_keys=True)}\n\n\n")
        raise ex


if __name__ == "__main__":
    sname = splunk_get_search_name()
    trips = splunk_get_search_results(sname)

    for fromPlace, toPlace in trips:
        for date in get_testing_dates():
            arriveBy = bool(getrandbits(1))

            print(f"Comparing plans from {fromPlace} to {toPlace} {'arriving by' if arriveBy else 'departing on'} {date}")

            prod_plans = get_trip_plans("prod", fromPlace, toPlace, date, arriveBy)
            dev_plans = get_trip_plans("dev", fromPlace, toPlace, date, arriveBy)

            compare_plans(prod_plans, dev_plans)

    print("Test completed successfully")
