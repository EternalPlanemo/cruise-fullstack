module source.city;

import std.datetime.date;

class City
{
    string name;
    Date arrivalDate;
    int distance;

    this(string name, Date arrivalDate) {
        this.name = name;
        this.arrivalDate = arrivalDate;
    } 
}