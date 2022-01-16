module source.cruise;

import std.datetime.date;
import std.random : rndGen;

abstract class Cruise
{
    protected string fromCity;
    protected string toCity;
    protected Date startDate;
    protected int distance;
    protected bool againstTheCurrent;
    protected int id = -1;
    protected static int objCount = 0;

    this(string fromCity, string toCity, Date startDate, int distance) {
        this.fromCity = fromCity;
        this.toCity = toCity;
        this.startDate = startDate;
        this.distance = distance;
        this.againstTheCurrent = rndGen().front() % 2 == 1 ? true : false;
        this.objCount++;
        this.id = objCount;
    }

    void print();
    string toJson();

    string getFromCity() {
        return fromCity;
    }

    string getToCity() {
        return toCity;
    }

    Date getStartDate() {
        return  startDate;
    }

    int getId() {
        return id;
    }
}