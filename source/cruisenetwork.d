module source.cruisenetwork;

import source.cruisetype : CruiseType, Type;
import std.algorithm;
import std.conv;
import core.time : Duration;
import std.datetime.date;
import std.algorithm.sorting : sort;
import std.string : strip;

class CruiseNetwork
{
    private CruiseType[] cruises;

    this(CruiseType[] cruises) {
        this.cruises = cruises;
    }

    string getCruisesFromTo(string fromCity, string toCity) {
        auto matches = cruises.filter!(cruise => cruise.getFromCity() == fromCity && cruise.getToCity() == toCity);
        string result = "[ ";

        foreach (CruiseType key; matches) {
            result ~= key.toJson() ~ ", ";
        }

        result = result.strip(", ");

        result ~= " ]";

        return result;
    }

    string getCruisesBeforeStartDate(string fromCity, string toCity, string startDate) {
        auto matches = cruises.filter!(cruise => cruise.getFromCity() == fromCity && cruise.getToCity() == toCity);
        string result = "[ ";

        foreach (CruiseType key; matches) {
            Duration diff = Date.fromISOExtString(startDate) - key.getStartDate();

            if (diff.total!"days" < 0) {
                result ~= key.toJson() ~ ", ";
            }
        }

        result = result.strip(", ");
        result ~= "]";

        return result;
    }
    
    string getCruisesBeforeArrivalDate(string fromCity, string toCity, string arrivalDate) {
        auto matches = cruises.filter!(cruise => cruise.getFromCity() == fromCity && cruise.getToCity() == toCity);
        string result = "[ ";

        foreach (CruiseType key; matches) {
            Duration diff = Date.fromISOExtString(arrivalDate) - Date.fromISOExtString(key.getDateOfArrival(toCity));

            if (diff.total!"days" < 0) {
                result ~= key.toJson() ~ ", ";
            }
        }

        result = result.strip(", ");
        result ~= "]";

        return result;
    }

    string getFastestCruise(string fromCity, string toCity) {
        alias cmp = (x, y) => x.getTravelTime() > y.getTravelTime();

        cruises.sort!(cmp);

        return cruises.filter!(cruise => cruise.getFromCity() == fromCity && cruise.getToCity() == toCity).front().toJson();
    }

    string getAvgSpeedByType(string type) {
        Type t;
        string result;

        switch (type) {
            case "EXPRESS": t = Type.EXPRESS; break;
            default: t = Type.PASSANGER; break;
        }

        result = "[ ";

        for (int i = 0; i < cruises.length; ++i) {
            if (cruises[i].getType() == t)
            result ~= cruises[i].toJson();
        }

        result = result.strip(", ");
        result ~= " ]";

        return result;
    }
}